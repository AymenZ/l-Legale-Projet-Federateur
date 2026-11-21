# Backlog Produit & Matrice MoSCoW — I-Légale

> Classe **ISIL 3-1** · 10 User Stories (6 Must · 3 Should · 1 Could) · À reporter dans GitHub Projects (une Issue par US, label MoSCoW).

**Leads :** Aymen = IA & Data · Aziz = Backend & CI/CD · Wajdi = Frontend & UX/UI

---

## 1. Tableau du Backlog Initial

| ID | Priorité MoSCoW | User Story | Critères d'Acceptation (Definition of Done) | Assigné à | Séance Cible |
|:---:|:---:|:---|:---|:---:|:---:|
| **US-01** | **Must Have** | En tant qu'utilisateur (client ou juriste), je souhaite créer un compte et me connecter avec un rôle, afin d'accéder à mon espace privé et à des fonctionnalités adaptées à mon profil. | - Inscription avec choix du rôle `client` ou `juriste`<br>- Mot de passe hashé, token JWT vérifié sur les routes protégées<br>- Mauvais identifiants : message d'erreur explicite, aucun plantage | Aziz | S4 |
| **US-02** | **Must Have** | En tant qu'utilisateur, je souhaite déposer un contrat de travail (PDF, DOCX ou texte collé), afin qu'il soit analysé par le système. | - Formats acceptés : PDF texte, DOCX, texte collé ; taille max définie (ex. 10 Mo)<br>- Texte extrait et stocké ou hashé en base<br>- Format non supporté ou fichier illisible : message d'erreur clair | Aziz / Aymen | S4 |
| **US-03** | **Must Have** | En tant qu'utilisateur, je souhaite que le système analyse mon contrat clause par clause, afin de savoir quelles clauses sont conformes, risquées ou à vérifier. | - Le contrat est segmenté en clauses<br>- Retour d'un JSON validé par Pydantic (statut, niveau de risque, explication, correction suggérée)<br>- Sur le jeu de test annoté, les catégories de clauses sont mesurées et reportées dans la fiche de métriques<br>- Erreur du LLM ou JSON invalide : gérés sans plantage (nouvel essai puis message) | Aymen | S3 / S4 |
| **US-04** | **Must Have** | En tant qu'utilisateur, je souhaite que chaque non-conformité cite les articles du Code du travail applicables, afin de pouvoir vérifier la source de l'analyse. | - Chaque verdict `non_conforme` contient au moins un `article_ref` en vigueur avec son extrait<br>- Un article cité absent des passages récupérés est rejeté par la validation<br>- Aucun passage pertinent trouvé : statut `a_verifier`, pas d'invention | Aymen | S3 |
| **US-05** | **Must Have** | En tant qu'utilisateur, je souhaite visualiser les résultats dans un tableau de bord, afin de comprendre rapidement l'état de mon contrat. | - Clauses affichées avec indicateur visuel par niveau de risque<br>- Indicateur de chargement pendant l'analyse<br>- Articles cités et correction suggérée consultables par clause<br>- Avertissement « information juridique, pas un conseil » visible | Wajdi | S5 |
| **US-06** | **Must Have** | En tant qu'utilisateur, je souhaite que mon analyse soit enregistrée, afin de la retrouver plus tard. | - Analyse persistée en PostgreSQL avec clé étrangère vers l'utilisateur<br>- Un utilisateur ne peut accéder qu'à ses propres analyses<br>- Échec d'enregistrement : message d'erreur, résultat toujours affiché | Aziz | S4 |
| **US-07** | **Should Have** | En tant que juriste, je souhaite une analyse plus détaillée que celle d'un client, afin d'obtenir un pré-audit exploitable sans explications de base ; en tant que client, je souhaite une analyse simple avec un signalement quand un avis professionnel est nécessaire. | - Le mode (`client` ou `pro`) est déduit du rôle<br>- Mode pro : plus de sources et analyse détaillée ; mode client : explications simples<br>- `needs_professional = true` selon une règle déterministe (ex. risque élevé) et affiché au client | Aymen / Aziz | S4 / S5 |
| **US-08** | **Should Have** | En tant que client, je souhaite contacter un juriste inscrit lorsque mon contrat nécessite un avis professionnel, afin d'être orienté vers une personne compétente. | - Si `needs_professional = true`, liste des juristes du domaine avec leur email<br>- Liste visible uniquement par un client connecté<br>- Un juriste n'apparaît que s'il a coché « visible dans l'annuaire »<br>- Aucun juriste disponible : message neutre | Wajdi / Aziz | S5 |
| **US-09** | **Should Have** | En tant qu'utilisateur, je souhaite consulter l'historique de mes analyses, afin de suivre l'évolution de mes contrats. | - Liste paginée de mes analyses passées<br>- Filtre par date<br>- Clic sur une analyse : réaffichage du résultat sauvegardé | Wajdi / Aziz | S5 / S6 |
| **US-10** | **Could Have** | En tant qu'utilisateur, je souhaite exporter le rapport d'analyse en PDF, afin de le transmettre ou de l'archiver. | - Bouton « Exporter en PDF »<br>- Le PDF contient clauses, niveaux de risque, articles cités et avertissement | Wajdi | S6 |

---

## 2. Won't Have (hors périmètre des 7 séances)

Paiement et abonnement · prise de rendez-vous et messagerie client ↔ juriste · signature électronique · autres types de contrat (divorce, bail, commercial) · autres juridictions que le droit français · application mobile native · fine-tuning d'un LLM.

---

## 3. Template pour une User Story individuelle (Issue GitHub)

```markdown
### Description
En tant que [rôle],
Je souhaite [action],
Afin de [valeur métier].

### Priorité MoSCoW
- [ ] Must Have
- [ ] Should Have
- [ ] Could Have

### Critères d'Acceptation (Given - When - Then)
- **Scénario 1 : Cas nominal**
  - **Étant donné** [état initial du système]
  - **Quand** [l'utilisateur déclenche l'action]
  - **Alors** [le résultat attendu se produit]

- **Scénario 2 : Gestion d'erreur**
  - **Étant donné** [donnée d'entrée invalide]
  - **Quand** [l'action est soumise]
  - **Alors** [un message d'erreur explicite est renvoyé sans faire planter l'application]

### Dépendances techniques
- Lié au composant : [Frontend / Backend / Base de Données / Brique IA]
- Dépend de l'issue : #...
```
