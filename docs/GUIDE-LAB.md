# Guide du lab — Infrastructure durcie (Hyper-V)

Procédure complète et reproductible : un tiers doit pouvoir rejouer le lab de A à Z.

## 1. Architecture

| VM | Rôle | Zone | IP (exemple) |
|---|---|---|---|
| `bastion` | Point d'entrée, exposé | DMZ | 192.168.100.10 |
| `interne` | Serveur protégé | interne | 192.168.100.30 |

- Les 2 VM sont sur un **commutateur virtuel interne** Hyper-V `Lab-Durcissement` (réseau `192.168.100.0/24`).
- **Segmentation visée :** le bastion est joignable en SSH depuis le poste d'admin ; le serveur interne n'accepte le SSH **que depuis le réseau de la DMZ**.

## 2. Préparer les 2 VM Debian (Hyper-V)

1. Crée 2 VM **Debian 12** (génération 2, 2 Go RAM, 1 vCPU suffisent).
2. Rattache-les au commutateur interne `Lab-Durcissement`.
3. Donne-leur une IP fixe (`192.168.100.10` et `.30`), même sous-réseau.
4. À l'installation, crée ton utilisateur (ex. `styve`) et installe le serveur SSH :
   ```bash
   sudo apt update && sudo apt install -y openssh-server sudo
   ```
5. Depuis ton poste (WSL), copie ta clé SSH sur chaque VM (évite les mots de passe) :
   ```bash
   ssh-keygen -t ed25519        # si tu n'as pas encore de clé
   ssh-copy-id styve@192.168.100.10
   ssh-copy-id styve@192.168.100.20
   ```

## 3. Score Lynis AVANT (baseline)

Sur **chaque** VM :
```bash
sudo apt install -y lynis
sudo lynis audit system | tee /tmp/lynis-before.txt
```
Note le **Hardening index** affiché à la fin, et récupère les fichiers dans `reports/lynis-before.txt`.

| Serveur | Hardening index AVANT |
|---|---|
| bastion | _à remplir_ |
| interne | _à remplir_ |

## 4. Appliquer le durcissement (Ansible)

Depuis `ansible/` sur ton poste (WSL) :
```bash
# 1. Renseigne les IP de tes VM dans inventory.ini
# 2. Installe les collections requises
ansible-galaxy collection install -r requirements.yml
# 3. Teste la connexion
ansible all -m ping
# 4. Applique le durcissement
ansible-playbook site.yml
```

> ⚠️ **Avant de durcir, assure-toi d'avoir ta clé SSH en place** (étape 2.5). Le playbook désactive l'authentification par mot de passe (`PasswordAuthentication no`). Si tu n'as pas encore de clé, mets `ssh_password_authentication: "yes"` dans `roles/hardening-base/defaults/main.yml` pour ce premier passage.

### Idempotence (critère noté)
Relance **exactement la même commande** :
```bash
ansible-playbook site.yml
```
Le récapitulatif doit afficher **`changed=0`** sur toutes les VM → preuve que le playbook est idempotent. Fais une capture d'écran.

## 5. Score Lynis APRÈS + delta

Sur chaque VM :
```bash
sudo lynis audit system | tee /tmp/lynis-after.txt
```
Récupère `reports/lynis-after.txt` et remplis le tableau :

| Serveur | Avant | Après | Delta |
|---|---|---|---|
| bastion | _ | _ | _ |
| interne | _ | _ | _ |

## 6. Tests de flux (segmentation — 25 pts)

Objectif : **prouver** que la segmentation marche. Fais des captures d'écran.

**Flux autorisé** (depuis le bastion vers l'interne, port 22) :
```bash
# sur le bastion
nc -zv 192.168.100.30 22     # doit REUSSIR (succeeded)
```

**Flux bloqué** (depuis une machine hors DMZ vers l'interne) :
```bash
# depuis ton poste (hors sous-reseau DMZ) ou une 3e machine
nmap -p 22 192.168.100.30    # le port doit apparaitre filtered/closed
nc -zv 192.168.100.30 22     # doit ECHOUER (timed out / refused)
```

**Web sur le bastion** (si tu exposes un service) :
```bash
curl -I http://192.168.100.10   # repond ; curl http://192.168.100.30 depuis l'exterieur doit echouer
```

## 7. Règles CIS appliquées (extrait)

| Domaine | Règles CIS | Rôle Ansible |
|---|---|---|
| SSH (root, mot de passe, MaxAuthTries, X11, timeout, bannière) | 5.1.x | hardening-base |
| Permissions fichiers de comptes | 6.1.x | hardening-base |
| Paramètres réseau noyau (sysctl) | 3.3.x | hardening-base |
| Mises à jour de sécurité auto | 1.2.x | hardening-base |
| Politique de mots de passe (pwquality) | 5.3.1 | hardening-base |
| Systèmes de fichiers inutiles | 1.1.1.x | hardening-base |
| Pare-feu ufw par zone | 3.5.x | firewall-rules |
| Audit (auditd + règles) | 4.1.x | audit-logging |
| Journalisation persistante | 4.2.1.x | audit-logging |
