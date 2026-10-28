# Captures de preuve — Projet 02

Captures d'écran documentant chaque étape de l'évolution du projet, dans l'ordre chronologique.

| # | Fichier | Étape prouvée |
|---|---|---|
| 01 | `01-installation-wsl.png` | Mise en place du poste de pilotage (WSL) |
| 02 | `02-installation-terraform.png` | Installation de Terraform v1.16.5 |
| 03 | `03-terraform-init-structure.png` | `terraform init` + structure du code IaC |
| 04 | `04-terraform-plan-vpc-sous-reseaux.png` | `terraform plan` — VPC + sous-réseaux DMZ/privé |
| 05 | `05-terraform-plan-igw-security-groups.png` | `terraform plan` — passerelle + security groups |
| 06 | `06-lynis-avant-bastion-64.png` | Baseline Lynis bastion = 64/100 |
| 07 | `07-lynis-avant-interne-68.png` | Baseline Lynis interne = 68/100 |
| 08 | `08-ansible-premiere-application-changed7.png` | 1ʳᵉ application du durcissement (`changed=7`) |
| 09 | `09-ansible-2e-passage-changed1-avant-correctif.png` | 2ᵉ passage : 1 tâche non idempotente détectée (`changed=1`) |
| 10 | `10-ansible-idempotence-changed0.png` | Après correctif : `changed=0` (idempotence) |
| 11 | `11-lynis-apres-bastion-70.png` | Lynis bastion après = 70/100 (+6) |
| 12 | `12-lynis-apres-interne-73.png` | Lynis interne après = 73/100 (+5) |
| 13 | `13-ufw-segmentation-interne.png` | ufw : SSH autorisé uniquement depuis la DMZ |
| 14 | `14-remediation-docker-fermeture-port80.png` | Découverte Docker/ufw + fermeture du port 80 |
| 15 | `15-tests-flux-segmentation-bastion.png` | Tests de flux : nc 22 OK / 80 bloqué + nmap |
