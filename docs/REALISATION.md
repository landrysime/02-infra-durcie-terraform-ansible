# Projet 02 — De l'énoncé à la réalisation

Ce document fait le lien entre **l'énoncé initial** du projet et **ce qui a réellement été réalisé**.
Objectif : qu'un lecteur (recruteur, formateur, ou moi-même plus tard) puisse se retrouver dans le projet,
comprendre les choix d'architecture et **pourquoi la démarche a évolué** en cours de route.

---

## 1. Énoncé initial (rappel)

> Migrer une infrastructure gérée manuellement vers l'Infrastructure as Code. Le RSSI exige une
> **segmentation réseau avec DMZ**, un **pare-feu**, et la **conformité CIS Benchmark** documentée
> avec un **rapport avant/après chiffré**.

**Livrables attendus :** code Terraform en modules (VPC, Security Groups) · playbooks Ansible ≥ 3 rôles ·
schéma réseau DMZ/interne (flux autorisés/bloqués) · rapports Lynis avant/après avec delta chiffré.

**Barème (100 pts) :** segmentation testée **25** · idempotence IaC **20** · couverture CIS **20** ·
delta Lynis **20** · documentation/reproductibilité **15**.

---

## 2. Les 2 virages de démarche (et pourquoi)

L'objectif de sécurité (segmentation + durcissement CIS + preuve chiffrée) a été **tenu à 100 %**.
En revanche, **2 briques techniques ont été remplacées par des équivalents**, pour des raisons concrètes.
C'est un réflexe de terrain : on garde l'objectif, on adapte l'outil aux contraintes.

### 🔀 Virage 1 — Le cloud AWS → le lab Hyper-V

| | |
|---|---|
| **Prévu** | Créer un compte AWS Free Tier, faire tourner `terraform apply` / `destroy` sur de vraies instances EC2. |
| **Rencontré** | Le compte AWS ouvert est un nouveau **« Free Plan »** dont la politique (Service Control Policy) **interdit explicitement la création d'EC2** (`UnauthorizedOperation ... explicit deny in service control policy`). Passer en compte payant exigeait **une carte bancaire**. |
| **Décision** | **Ne pas saisir de carte bancaire** (choix assumé — maîtrise du risque de facturation), et **réaliser le lab sur Hyper-V** (gratuit, local, déjà disponible sur le poste). |
| **Conséquence** | Le code **Terraform est conservé et validé** (`terraform init` + `terraform plan` → `Plan: 8 to add`) comme **preuve de la compétence IaC cloud**, mais le durcissement réel et les tests sont menés sur les 2 VM Hyper-V. |

➡️ **Ce qu'on y gagne en lecture :** la compétence Terraform est démontrée (modules, variables, plan validé)
sans dépendre d'un compte cloud bloqué, et le durcissement Ansible — le vrai cœur du projet — tourne sur
une infra 100 % maîtrisée.

### 🔀 Virage 2 — Le pare-feu pfSense → le pare-feu `ufw` par zone (host-based)

| | |
|---|---|
| **Prévu** | Une VM **pfSense** avec 3 interfaces (WAN / DMZ / LAN) comme pare-feu central. |
| **Rencontré** | Le poste **n'avait plus assez de ressources** pour une 3ᵉ VM (pfSense) en plus des 2 serveurs Debian. |
| **Décision** | Assurer la **segmentation par le réseau Hyper-V** (commutateur interne isolé `192.168.100.0/24` + bastion dual-homed) et le **filtrage par `ufw` configuré par zone directement sur les hôtes** (host-based firewall), piloté par Ansible (rôle `firewall-rules`). |
| **Conséquence** | Même résultat de sécurité — *« l'interne n'accepte le SSH que depuis la DMZ, tout le reste est refusé »* — mais **automatisé et versionné** (le pare-feu est du code Ansible, pas une config cliquée dans une interface). |

➡️ **Ce qu'on y gagne en lecture :** le filtrage devient **as-code et idempotent** (cohérent avec l'esprit IaC du projet),
et la segmentation reste **prouvable par des tests de flux** (nc / nmap).

> **Bonus imprévu :** pendant les tests, le port 80 de l'interne est resté ouvert **malgré ufw** → découverte que
> **Docker insère ses règles iptables en amont d'ufw**. Remédiation appliquée (arrêt du conteneur + désactivation de Docker).
> Un vrai apprentissage de production, absent de l'énoncé.

---

## 3. Plan jour par jour : prévu → réalisé

| Étape de l'énoncé | Prévu | Réalisé | Statut |
|---|---|---|---|
| **Outils + squelette** | Comptes AWS, MFA, IAM, budget 1 $ ; Terraform/AWS CLI/Ansible (WSL) ; dépôt + arborescence | WSL + Terraform + Ansible installés ; dépôt `02-infra-durcie-terraform-ansible` créé ; arborescence `terraform/` + `ansible/roles/` | ✅ (AWS remplacé par Hyper-V) |
| **Modules VPC + SG** | Terraform `apply` d'un VPC DMZ/privé + security groups | Code Terraform écrit (VPC, sous-réseaux DMZ/privé, SG : interne joignable seulement depuis la DMZ) et **validé par `terraform plan`** | ✅ (plan validé, apply bloqué par AWS) |
| **Pare-feu + schéma** | VM pfSense 3 interfaces + export `config.xml` | Segmentation Hyper-V (switch interne + bastion 2 cartes) + **`ufw` par zone via Ansible** ; schéma réseau dans le README | ✅ (pfSense remplacé par ufw) |
| **Lynis AVANT** | `lynis audit system` sur les 2 VM → baseline | bastion **64/100**, interne **68/100** → `reports/lynis-before.txt` | ✅ |
| **Durcissement Ansible** | `inventory.ini` + `site.yml` + 3 rôles (hardening-base, firewall-rules, audit-logging), chaque tâche numérotée CIS, idempotence `changed=0` | 3 rôles livrés, tâches référencées CIS, **idempotence atteinte (`changed=0`)** après correctif sysctl | ✅ |
| **Lynis APRÈS + flux + README** | Nouveau Lynis + delta + tests de flux (nc/curl/nmap) + README reproductible | bastion **70** (+6), interne **73** (+5) ; flux : `nc 22` OK / `nc 80` bloqué / `nmap` → seul 22 ouvert ; README complet + captures | ✅ |

---

## 4. Barème : où en est chaque critère

| Critère | Points | Comment c'est couvert | Preuve |
|---|---|---|---|
| Segmentation réseau testée | 25 ⭐ | ufw par zone + switch interne ; tests nc/nmap depuis le bastion | `screenshots/13`, `15` |
| Idempotence du code IaC | 20 | Rôles Ansible ; 2ᵉ passage `changed=0` (après correctif sysctl) | `screenshots/08`→`10` |
| Couverture CIS numérotée | 20 | ~18 contrôles CIS Debian 12 référencés par numéro dans les rôles | `ansible/roles/`, README |
| Delta Lynis chiffré | 20 | 64→70 et 68→73 | `screenshots/06`, `07`, `11`, `12` + `reports/` |
| Documentation reproductible | 15 | README 5 phases + `GUIDE-LAB.md` | `README.md`, `docs/GUIDE-LAB.md` |

---

## 5. Structure du dépôt : prévue → réelle

| Prévu (énoncé) | Réel | Note |
|---|---|---|
| `terraform/` + `modules/vpc/` + `modules/security_groups/` | `terraform/` (main.tf, network.tf, variables.tf) | Architecture complète en un dossier ; validée par `plan` |
| `ansible/` + `roles/{hardening-base,firewall-rules,audit-logging}` | ✅ identique | 3 rôles |
| export pfSense `config.xml` | — | Remplacé : le pare-feu est dans `roles/firewall-rules/` (as-code) |
| `reports/lynis-before.txt` + `after.txt` | ✅ | — |
| `README.md` (schéma + procédure + tableau CIS) | ✅ + `docs/GUIDE-LAB.md` + `screenshots/` | Rapport enrichi |

---

*En résumé : l'objectif de sécurité et les 5 critères du barème sont tenus. Les 2 substitutions
(AWS→Hyper-V, pfSense→ufw) sont des adaptations assumées à des contraintes réelles — compte cloud bloqué
et ressources matérielles — et chacune est documentée et justifiée.*
