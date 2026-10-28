# Conformité CIS — delta Lynis avant / après

Mesure réalisée avec **Lynis 3.1.4** sur les 2 machines, avant puis après
application du playbook Ansible de durcissement.

| Serveur | Zone | Hardening index AVANT | Hardening index APRÈS | Gain |
|---|---|---|---|---|
| bastion (192.168.100.10) | DMZ | 64 / 100 | **70 / 100** | **+6** |
| interne (192.168.100.30) | interne | 68 / 100 | **73 / 100** | **+5** |

## Lecture

- Le durcissement a **augmenté le niveau de conformité** des deux serveurs,
  de façon mesurable et reproductible (playbook idempotent, `changed=0` au 2ᵉ passage).
- Les contrôles appliqués couvrent : SSH (CIS 5.1), permissions des fichiers de
  comptes (6.1), paramètres réseau noyau (3.3), mises à jour de sécurité auto (1.2),
  politique de mots de passe (5.3.1), systèmes de fichiers inutiles (1.1.1),
  pare-feu ufw par zone (3.5), audit auditd (4.1) et journalisation persistante (4.2.1).

## Pistes d'amélioration (restantes côté Lynis)

Lynis signale encore des points non couverts par ce périmètre, qui permettraient
de gagner d'autres points :
- **Malware scanner [X]** : installer rkhunter ou chkrootkit (CIS / HRDN-7230).
- **Intégrité des fichiers** : AIDE (CIS 6.1.1).
- **Durcissement noyau supplémentaire** et profils AppArmor.

Ces éléments sont volontairement hors périmètre de cette itération pour garder
un playbook lisible et ciblé ; ils constituent la suite logique du durcissement.
