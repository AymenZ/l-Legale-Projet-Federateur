# Fiche de Cadrage Express — Projet Fédérateur

> Classe **ISIL 3-1** · Module Développement Fullstack & Intégration IA · Séance 1 (Idéation & Cadrage)

---

## 1. Identité du Projet

* **Nom du projet :** **I-Légale**
* **Pitch en une phrase :** I-Légale est une application web permettant aux salariés, aux petits employeurs et aux juristes de vérifier la conformité des clauses d'un contrat de travail au droit français grâce à un RAG sur le Code du travail qui cite les articles applicables, afin de remplacer une recherche manuelle de plusieurs dizaines de minutes par une analyse clause par clause en moins d'une minute.
* **Membres de l'équipe (3) & Répartition des rôles :**
  1. *Mohammed Aymen Zouaoui* — **Rôle :** Lead IA & Data (corpus, embeddings, pipeline RAG, jeu d'évaluation)
  2. *Mohmed Aziz Hameza* — **Rôle :** Lead Backend & CI/CD (API FastAPI, base de données, Docker, GitHub Actions)
  3. *Wajdi Hachana* — **Rôle :** Lead Frontend & UX/UI (React, parcours utilisateur, tableau de bord)

> Équipe de 3 : le rôle DevOps est fusionné avec Backend. Les Pull Requests sont relues en croisé (chaque lead relit le code d'un autre).

---

## 2. Problématique Métier & Utilisateurs Cibles

* **Quel est le problème concret à résoudre ?**
  Un salarié qui reçoit un contrat de travail, ou un petit employeur qui le rédige à partir d'un modèle trouvé en ligne, n'a pas les moyens de savoir si chaque clause respecte le Code du travail (période d'essai, non-concurrence, durée du travail, rémunération, rupture, mobilité…). Vérifier oblige soit à chercher à la main dans des milliers d'articles, soit à payer un juriste pour un document de quelques pages. Une clause irrégulière passe alors inaperçue et ressort plus tard sous forme de litige. Côté professionnels, les juristes refont clause par clause les mêmes vérifications répétitives sur chaque contrat.
* **Qui sont les utilisateurs finaux (Personas) ?**
  * *Persona primaire :* un salarié ou un dirigeant de TPE qui doit signer ou rédiger un contrat de travail sans formation juridique et veut savoir quelles clauses sont conformes, risquées ou à faire vérifier.
  * *Persona secondaire :* un juriste RH ou un avocat en droit social qui contrôle de nombreux contrats et veut un pré-audit sourcé, avec les articles applicables, pour gagner du temps.

---

## 3. Rôle Précis de la Brique IA (Anti-Gadget)

* **Pourquoi l'IA est-elle indispensable ici (et non un simple algorithme déterministe) ?**
  Une même règle s'écrit de dizaines de façons dans un contrat. Il est impossible de la détecter avec des règles `if/else` sur du texte libre. Il faut (1) repérer et catégoriser les clauses, (2) retrouver sémantiquement les articles applicables parmi plusieurs milliers, (3) comparer et expliquer l'écart. Un LLM seul inventerait des articles ou citerait des règles abrogées. Le **RAG** ancre chaque réponse sur le texte légal en vigueur et impose la citation. Quand rien de pertinent n'est retrouvé, le système répond « à vérifier » et n'invente jamais.

* **Type d'approche IA envisagée :**
  [x] RAG (Retrieval-Augmented Generation avec base vectorielle)
  [ ] Modèle d'apprentissage automatique supervisé (Scikit-Learn / XGBoost)
  [ ] Modèle de Deep Learning pré-entraîné (Hugging Face Transformers / Vision)
  [ ] Agent LLM avec appel d'outils structurés (Tool Calling / Function Calling)

  *Hugging Face est utilisé uniquement pour les modèles d'embeddings (et éventuellement un reranker), pas pour entraîner un modèle.*

* **Pipeline d'inférence :**
  1. Extraction du texte du contrat (PDF / DOCX / texte collé).
  2. Segmentation du contrat en clauses.
  3. Retrieval : recherche des top-k articles pertinents dans pgvector (embeddings multilingues), reranking optionnel.
  4. Génération : le LLM rend un verdict par clause **uniquement à partir des extraits récupérés**, au format JSON.
  5. Validation déterministe : schéma Pydantic + vérification que chaque article cité figure bien parmi les passages récupérés (garde-fou anti-hallucination).
  6. Règle déterministe pour `needs_professional` (voir backlog).

* **Données exploitées (Data Source) :**
  * **Code du travail** (partie législative et réglementaire), open data DILA / Légifrance : jeu de données Hugging Face `louisbrulenaudet/code-travail` (licence apache-2.0) ou base LEGI sur data.gouv.fr (Licence Ouverte V2.0, mention de la DILA obligatoire). Filtrage obligatoire des **articles en vigueur uniquement**.
  * **Fiches pratiques du ministère du Travail** (dépôt `SocialGouv/fiches-travail-data`) pour les explications en langage simple du mode client (licence à vérifier).
  * **Contrats d'exemple** : modèles CDI / CDD du ministère du Travail (code.travail.gouv.fr) et de Service-Public, utilisés comme base de test.
  * **Jeu de test annoté** : 20 à 30 clauses conformes / non conformes, fabriquées par l'équipe à partir des modèles (clauses volontairement modifiées), avec le verdict attendu.

* **Entrées et Sorties de l'IA :**
  * *Données d'entrée (Input) :* contrat de travail de quelques pages (PDF, DOCX ou texte), mode d'analyse (`client` ou `pro`).
  * *Données de sortie (Output) :* JSON structuré (exemple illustratif) :

```json
{
  "contract_id": "uuid",
  "mode": "client",
  "global_risk_level": "moyen",
  "needs_professional": true,
  "clauses": [
    {
      "clause_id": "c3",
      "text_extract": "La période d'essai est fixée à ...",
      "category": "periode_essai",
      "status": "non_conforme",
      "risk_level": "eleve",
      "explanation": "Durée supérieure au maximum prévu par la loi.",
      "suggested_correction": "Ramener la durée à ...",
      "sources": [
        { "article_ref": "L1221-19", "extract": "..." }
      ]
    }
  ],
  "disclaimer": "Information juridique non contractuelle, ne remplace pas l'avis d'un professionnel."
}
```
  *`status` ∈ {`conforme`, `non_conforme`, `a_verifier`} · `risk_level` ∈ {`faible`, `moyen`, `eleve`}.*

* **Évaluation prévue (Séance 3) :** taux de bonnes catégories de clauses, hit@k du retrieval sur le jeu annoté, taux de citations valides (objectif : 100 %, garanti par la vérification déterministe), latence par contrat.

---

## 4. Architecture Technique Cible

| Couche | Technologie |
|:---|:---|
| **Frontend** | React (JavaScript) + Vite, client HTTP (fetch / Axios) |
| **Backend** | FastAPI (Python), Pydantic, SQLAlchemy + Alembic, authentification JWT |
| **Base de données** | PostgreSQL 16 + extension **pgvector** (Docker) |
| **Composant IA / Moteur** | LangChain (orchestration, text splitters) · embeddings multilingues `sentence-transformers` (Hugging Face), modèle à benchmarker en S3 · reranker optionnel · LLM à trancher en S3 (Ollama local ou API avec clé gratuite) · `pypdf` / `python-docx` pour l'extraction · Pydantic pour la validation de sortie |
| **Qualité / CI** | Pytest (IA mockée), Ruff, GitHub Actions |
| **Conteneurisation** | Docker Compose (`docker compose up --build`) |
| **Hébergement cible (Séance 7)** | Render / Railway pour l'API et la base (à vérifier : support de pgvector), Vercel pour le frontend |

---

## 5. Périmètre Fonctionnel (Matrice MoSCoW — Version Initiale)

### Must Have (MVP — Fonctionnel à la Séance 5)
1. Authentification avec deux rôles (client / juriste) et dépôt d'un contrat de travail (PDF, DOCX ou texte).
2. Analyse RAG clause par clause : JSON validé avec statut, niveau de risque, correction suggérée et **citation des articles du Code du travail en vigueur**.
3. Affichage de l'analyse dans un tableau de bord réactif et sauvegarde en base PostgreSQL liée à l'utilisateur.

### Should Have (Fonctionnalités secondaires — Séance 6)
1. Profondeur différente selon le rôle (client : explications simples ; juriste : analyse détaillée) et signalement `needs_professional`.
2. Renvoi vers un juriste : liste des juristes du domaine avec leur email, visible uniquement par un client connecté ; les juristes choisissent d'être listés.
3. Historique des analyses précédentes avec filtre par date.

### Could Have (Bonus si l'équipe est en avance)
1. Export PDF du rapport d'analyse.
2. Validation ou commentaire d'un juriste sur une analyse.
3. Prise en compte d'une seule convention collective.
4. Mode sombre, notifications email.

### Won't Have (Explicitement exclu des 7 semaines)
1. Paiement, abonnement, facturation.
2. Prise de rendez-vous et messagerie interne client ↔ juriste.
3. Signature électronique.
4. Autres types de contrat (divorce, bail, commercial…) et autres juridictions que le droit français.
5. Application mobile native, fine-tuning ou entraînement d'un LLM.

---

## 6. Analyse des Risques Préliminaires

| Risque identifié | Niveau (Faible/Moyen/Élevé) | Solution de mitigation prévue |
|:---|:---:|:---|
| Hallucination ou erreur juridique du LLM | Élevé | Génération uniquement à partir des extraits récupérés ; vérification déterministe des articles cités ; réponse « à vérifier » si le retrieval est insuffisant ; avertissement visible (information juridique, pas un conseil) |
| Corpus obsolète ou doublons d'articles (états MODIFIÉ / VIGUEUR) | Moyen | Filtrage strict sur les articles en vigueur dès l'ingestion ; contrôle de la date du jeu de données |
| Extraction PDF / Word de mauvaise qualité | Moyen | Formats limités (PDF texte, DOCX, texte collé) ; tests sur les modèles officiels ; message d'erreur clair si illisible |
| Latence d'inférence (LLM + retrieval) | Moyen | Loader dans l'interface ; traitement clause par clause avec limite de k ; modèle local léger en secours |
| Quota ou indisponibilité de l'API LLM | Moyen | Clés personnelles gratuites ou Ollama en local ; couche LLM interchangeable |
| Dérive de périmètre (marketplace trop large) | Moyen | Won't Have explicite ; renvoi vers juriste limité à une liste avec email ; plan B : simple message « consultez un professionnel » |
| Charge inégale et dépendances entre rôles (équipe de 3) | Moyen | PR relues en croisé ; contrat d'interface (schéma JSON) figé dès la Séance 2 |

---

## 7. Décision de l'Enseignant (Rempli lors de l'Heure 3)

* **Note obtenue (sur 20) :** ______ / 20
* **Statut :** [ ] Validé  |  [ ] Réajustement requis  |  [ ] Refusé
* **Commentaires & Arbitrage :**
  * *Points forts :*
  * *Modifications obligatoires avant la Séance 2 :*
