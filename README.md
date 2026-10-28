# Projet 02 — Infrastructure durcie as-code (Ansible + CIS)

Durcissement automatisé de serveurs Linux selon le **CIS Benchmark**, dans une architecture réseau **segmentée (DMZ + zone interne)**, avec preuve de conformité **avant / après** mesurée par Lynis et tests de flux de segmentation.

**Stack :** Ansible · ufw · auditd · Lynis · Hyper-V · Debian 12 · (+ Terraform AWS en bonus IaC)

---

## 🎯 Contexte

Une entreprise migre son infrastructure, gérée manuellement, vers une approche **Infrastructure as Code**. Le RSSI exige une **segmentation réseau** (DMZ), un durcissement conforme à un **référentiel reconnu (CIS)**, et un **rapport de conformité chiffré** avant/après. Le durcissement doit être **reproductible** et **idempotent**.

## 🧱 Architecture

```
        Internet / poste d'administration
                     │
             [ NAT — Default Switch ]
                     │  (carte 2 du bastion)
              ┌──────────────┐
              │   BASTION     │   DMZ — 2 cartes réseau
              │ 192.168.100.10│   (SSH exposé, point de rebond)
              └──────────────┘
                     │  (carte 1)
   ===== LAN-Interne  192.168.100.0/24 =====
                     │
              ┌──────────────┐
              │   INTERNE     │   zone interne — 1 carte, isolé
              │ 192.168.100.30│   (joignable SSH uniquement depuis la DMZ)
              └──────────────┘
```

| VM | Zone | Rôle | Réseau |
|---|---|---|---|
| bastion | DMZ | Point d'entrée exposé + poste de pilotage Ansible | 2 cartes (LAN-Interne + NAT) |
| interne | interne | Serveur protégé, durci | 1 carte (LAN-Interne), isolé |

## 🗂️ Structure du dépôt

```
ansible/
  site.yml                      # playbook principal
  inventory.ini                 # 2 zones : [dmz] et [interne]
  group_vars/{dmz,interne}.yml  # règles pare-feu par zone
  roles/
    hardening-base/             # SSH, sysctl, permissions, MAJ auto, pwquality, FS
    firewall-rules/             # ufw : deny par défaut + règles par zone
    audit-logging/              # auditd + règles CIS + journald persistant
docs/
  GUIDE-LAB.md                  # procédure complète A→Z (reproductible)
  score-comparison.md           # delta Lynis détaillé
reports/
  lynis-before.txt / lynis-after.txt
terraform/                      # équivalent IaC cloud (AWS) — bonus, voir plus bas
screenshots/                    # preuves (à déposer)
```

## 🔒 Durcissement CIS appliqué

Chaque tâche Ansible référence **son numéro de règle CIS Debian 12**.

| Domaine | Règles CIS | Rôle |
|---|---|---|
| SSH (root, mot de passe, MaxAuthTries, X11, timeout, bannière) | 5.1.x | hardening-base |
| Permissions des fichiers de comptes (passwd/shadow/…) | 6.1.x | hardening-base |
| Paramètres réseau noyau (redirects, source-route, martians, syncookies, rp_filter) | 3.3.x | hardening-base |
| Mises à jour de sécurité automatiques | 1.2.x | hardening-base |
| Politique de mots de passe (pwquality) | 5.3.1 | hardening-base |
| Systèmes de fichiers inutiles désactivés | 1.1.1.x | hardening-base |
| Pare-feu ufw par zone (deny par défaut) | 3.5.x | firewall-rules |
| Audit système (auditd + règles) | 4.1.x | audit-logging |
| Journalisation persistante | 4.2.1.x | audit-logging |

## 📊 Résultats — conformité Lynis avant / après

| Serveur | Zone | AVANT | APRÈS | Gain |
|---|---|---|---|---|
| bastion (192.168.100.10) | DMZ | 64 / 100 | **70 / 100** | **+6** |
| interne (192.168.100.30) | interne | 68 / 100 | **73 / 100** | **+5** |

*(Lynis 3.1.4 — rapports complets dans `reports/`.)*

![Lynis avant](screenshots/lynis-avant.png)
![Lynis après](screenshots/lynis-apres.png)

## ♻️ Idempotence

Le playbook est **idempotent** : un 2ᵉ passage ne modifie plus rien.

```
PLAY RECAP
bastion : ok=27  changed=0  failed=0
interne : ok=27  changed=0  failed=0
```

![Idempotence](screenshots/ansible-idempotence-changed0.png)

## 🧪 Segmentation — tests de flux

Le serveur interne n'accepte le SSH **que depuis le réseau de la DMZ** ; tout le reste est bloqué.

```
# ufw status (interne)
22/tcp   ALLOW IN   192.168.100.0/24   # SSH depuis DMZ uniquement
Default: deny (incoming)
```

Tests depuis le bastion :

| Test | Commande | Résultat |
|---|---|---|
| Flux autorisé | `nc -zv 192.168.100.30 22` | **succeeded** ✅ |
| Flux bloqué | `nc -zv -w3 192.168.100.30 80` | **timed out** ✅ |
| Scan de ports | `nmap -Pn 192.168.100.30` | **seul `22/tcp open`** ✅ |

![Segmentation](screenshots/flux-segmentation-dmz-vers-interne.png)

## 🔎 Découverte : Docker contourne ufw

Lors des tests, le port 80 du serveur interne est resté **ouvert malgré ufw** : un conteneur Docker (DVWA, hérité du lab précédent) publiait le port 80. **Docker insère ses propres règles iptables en amont d'ufw**, contournant le pare-feu — un piège classique en production.

**Correctif appliqué** (fait partie du durcissement : un serveur interne durci ne doit pas héberger de service vulnérable exposé) :
```bash
sudo docker stop $(sudo docker ps -q)
sudo systemctl disable --now docker docker.socket
```
→ port 80 fermé, `nmap` ne montre plus que le 22. (En production : utiliser `ufw-docker` ou publier les ports sur `127.0.0.1` uniquement.)

## 🔁 Reproduire le lab

Procédure complète détaillée dans **[`docs/GUIDE-LAB.md`](docs/GUIDE-LAB.md)** :
1. 2 VM Debian 12 sur commutateur interne `192.168.100.0/24` (bastion 2 cartes, interne 1 carte).
2. Lynis AVANT → baseline.
3. `ansible-playbook site.yml` depuis le bastion (poste de pilotage).
4. 2ᵉ passage → `changed=0` (idempotence).
5. Lynis APRÈS → delta.
6. Tests de flux (nc / nmap).

> Note sécurité : le compte d'automatisation Ansible utilise un `sudo` sans mot de passe (choix de lab). En production, on utiliserait **Ansible Vault** pour le mot de passe sudo.

## ☁️ Bonus — IaC équivalente sur AWS (Terraform)

Le dossier `terraform/` contient l'équivalent de cette architecture **en Infrastructure as Code sur AWS** : VPC, sous-réseaux DMZ/privé, security groups (SSH restreint à une IP d'admin, interne joignable seulement depuis la DMZ), 2 instances. Code validé (`terraform plan`). Il démontre la même logique de segmentation, côté cloud.

## 🎓 Compétences démontrées

Durcissement CIS automatisé et **idempotent** (Ansible, rôles) · segmentation réseau et pare-feu par zone (ufw) · audit système (auditd) · mesure de conformité (Lynis, delta chiffré) · architecture DMG/bastion · compréhension des interactions Docker/pare-feu · documentation reproductible · IaC (Ansible + Terraform).

---

*Projet réalisé en autonomie — Styve Landry SIME KOUNOU — styvelandry1@outlook.fr — octobre 2026*
