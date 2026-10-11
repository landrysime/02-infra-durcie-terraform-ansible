# 02-infra-durcie-terraform-ansible
Énoncé du projet
Migrer une infrastructure gérée manuellement vers l'Infrastructure as Code. Le RSSI exige une segmentation réseau avec DMZ, un pare-feu pfSense, et la conformité CIS Benchmark documentée avec un rapport avant/après chiffré.

Livrable attendu : 
●	Code Terraform en modules (VPC, Security Groups)
●	Playbooks Ansible avec ≥ 3 rôles de durcissement
●	Schéma réseau DMZ/interne avec flux autorisés et bloqués
●	Rapports Lynis avant/après avec delta de conformité chiffré


Barème (100 points)
Critère	Points	Priorité
Segmentation réseau effective (tests de flux)	25	⭐ Critique
Qualité et idempotence du code IaC (modules)	20	Élevée
Couverture CIS (nombre de règles numérotées)	20	Élevée
Delta de conformité Lynis chiffré (avant/après)	20	Élevée
Documentation et reproductibilité (README)	15	Importante

⚠️  Note : les tests de flux (25 pts) sont la démonstration la plus visible — préparer des captures nmap/curl/nc.

Plan jour par jour

· Comptes, outils et squelette Terraform

Objectif : Préparer l'environnement et valider le premier apply/destroy.
●	AWS Free Tier : créer le compte + MFA sur root + utilisateur IAM dédié + alerte budget à 1 $
●	Installer Terraform, AWS CLI, Ansible (WSL si Windows) puis aws configure
●	Créer le dépôt 02-infra-durcie-terraform-ansible + .gitignore (exclure .terraform/ *.tfstate *.tfvars *.pem)
●	Arborescence : terraform/main.tf, variables.tf, modules/vpc/, modules/security_groups/
●	Test rapide : 1 EC2 t2.micro → terraform apply puis terraform destroy
●	Commit dès que ça fonctionne

Preuve attendue : dépôt créé + arborescence modules committée

· Modules VPC + Security Groups

Objectif : Créer l'architecture segmentée en 2 sous-réseaux.
●	Module vpc : 1 sous-réseau DMZ (public) + 1 sous-réseau interne (privé)
●	Module security_groups : DMZ → 80/443 ouverts, SSH limité à ton IP ; interne joignable UNIQUEMENT depuis la DMZ

●	Toutes les valeurs en variables (région, CIDR, type d'instance, ton IP) + Outputs : IP des serveurs
●	Commit + terraform destroy

Preuve attendue : terraform apply OK + modules committés

· pfSense en VM + règles + schéma réseau

Objectif : Ajouter le pare-feu et cartographier l'architecture.
●	VM pfSense (Hyper-V) avec 3 interfaces : WAN · DMZ · LAN interne
●	Règles : WAN → DMZ (80/443) ✅ · DMZ → interne (port applicatif seulement) ✅ · tout le reste ❌
●	Exporter la config pfSense dans le dépôt (config.xml)

●	Commit

Preuve attendue : schéma d'architecture + export config pfSense committés

· Lynis AVANT — score de conformité initial

Objectif : Photographier l'état de sécurité avant tout durcissement.
●	terraform apply → connexion SSH aux 2 serveurs
●	sudo apt install lynis && sudo lynis audit system sur les 2 VMs
●	Noter le Hardening index (ce score est la baseline du rapport)
●	Sauvegarder reports/lynis-before.txt
●	Lister les warnings/suggestions → choisir les règles CIS (avec numéro) à corriger le lendemain
●	Commit + terraform destroy

Preuve attendue : reports/lynis-before.txt + scores notés dans le tableau du Projet 02

Objectif : Automatiser le durcissement — c'est le cœur du projet.
●	inventory.ini (groupes dmz et interne) + site.yml
●	Rôle hardening-base : SSH sans root/mot de passe/MaxAuthTries · mises à jour auto · services inutiles désactivés · permissions fichiers sensibles · sysctl
●	Rôle firewall-rules : ufw ou nftables par zone
●	Rôle audit-logging : auditd + journalisation
●	Chaque tâche commentée avec son numéro CIS (ex. CIS 5.2.2)
●	Lancer 2 fois : le 2e passage doit afficher 0 changement — c'est l'idempotence, le critère qui impressionne les recruteurs
●	Vérifier que SSH fonctionne encore avant de fermer
●	Commit + terraform destroy

Preuve attendue : ansible/site.yml + roles/ committés + capture écran '0 changement'

 · Lynis APRÈS + tests de flux + delta + README

Objectif : Mesurer l'amélioration, prouver la segmentation, publier.
●	Relancer Lynis sur les 2 serveurs → noter les nouveaux scores → calculer le delta
●	Tests de flux (25 pts !) : prouver qu'un flux autorisé passe (curl, nc) et qu'un flux bloqué échoue (nmap) → captures d'écran obligatoires
●	Sauvegarder reports/lynis-after.txt
●	README : contexte · schéma · comment relancer (un tiers doit pouvoir reproduire) · règles CIS appliquées · tableau avant/après Lynis
●	Vérifier qu'aucun secret n'est dans le dépôt
●	Publier + terraform destroy final + vérifier la facturation AWS

Preuve attendue : README publié + reports/lynis-after.txt committés

Structure du dépôt GitHub
02-infra-durcie-terraform-ansible/
●	terraform/  ← main.tf, variables.tf
●	  modules/vpc/        ← sous-réseaux DMZ + interne
●	  modules/security_groups/ ← règles de filtrage
●	ansible/              ← inventory.ini, site.yml
●	  roles/hardening-base/  ← durcissement SSH, sysctl, services
●	  roles/firewall-rules/  ← ufw/nftables par zone
●	  roles/audit-logging/   ← auditd, journalisation
●	reports/              ← lynis-before.txt, lynis-after.txt
●	README.md             ← schéma + procédure + tableau CIS

Tableau de résultats — Lynis avant/après
