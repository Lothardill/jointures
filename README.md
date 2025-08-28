# Jointures en SQL

Ce dépôt regroupe une série d’exercices pratiques sur l’utilisation des jointures et transformations SQL dans un contexte métier (logistique, ventes, marketing, data quality, funnel commercial, etc.).

L’objectif est de développer une maîtrise progressive des principales notions SQL :
- Requêtes de base (sélection, filtres, conditions, agrégations simples)
- Jointures (INNER JOIN, LEFT JOIN, RIGHT JOIN, USING, ON) pour combiner plusieurs tables
- Tests de qualité des données pour valider l’intégrité et la cohérence des jeux de données
- Enrichissement et calcul d’indicateurs clés (KPIs logistiques, commerciaux et financiers)
- Analyses métier : suivi des expéditions, funnel commercial, performances de ventes, etc.

Chaque partie correspond à une compétence ou une notion particulière, et contient les fichiers SQL et jeux de données associés.

## Partie 1 – Jointure de base

Objectif : découvrir les bases du langage SQL (SELECT, WHERE, conditions, opérateurs logiques, CASE, IF, etc.).

Fichiers :
- `1-basic_queries.sql` : requêtes sur les clients (sélection, filtres, création de colonnes, panier moyen).
- `1-products.csv`, `1-products_segments.csv`, `1-promotions.csv`, `1-prices.csv`, `1-stocks.csv`, `1-categories.csv`, `1-sales_last3months.csv` : datasets.

## Partie 2 – Tests de qualité des données

Objectif : mettre en place des tests SQL pour valider l’intégrité des tables (clés primaires, valeurs NULL, cohérence des indicateurs).

Fichiers :

- `2-data_quality_tests.sql` : requêtes SQL de test (unicité des clés, valeurs nulles, contraintes métiers).
- `2-stock_raw.csv`, `2-stock_catalog.csv`, `2-stock_kpi.csv`, `2-sales_daily.csv` : datasets.

## Partie 3 – Analyse logistique des expéditions

Objectif : analyser et enrichir des données d’expédition afin de calculer des statuts, délais et indicateurs logistiques clés (temps de préparation, temps de livraison, taux de retard).

Fichiers :

- `3-shipments_analysis.sql` : requêtes SQL pour transformer les données brutes en tables enrichies (statuts, délais, KPIs).
- `3-shipments.csv`, `3-shipments_products.csv`, `3-shipments_enriched.csv`, `3-shipments_overview.csv`, `3-shipments_by_carrier.csv`, `3-shipments_by_priority.csv`, `3-shipments_by_month` : datasets.

## Partie 4 – Analyse du funnel commercial

Objectif : analyser et enrichir des données du funnel commercial afin de suivre les étapes de conversion (leads → opportunités → clients), calculer les taux de conversion et les délais moyens.

Fichiers :
- `4-sales_funnel_analysis.sql` : requêtes SQL pour explorer et enrichir les données du funnel (stages, taux, délais).
- `4-sales_funnel.csv` : dataset.

## Partie 5 – Analyse des ventes

Objectif : analyser les ventes (commandes, clients, produits) afin de calculer des agrégats clés par catégorie et sous-catégorie, et d’identifier les segments générateurs de chiffre d’affaires.

Fichiers :
- `5-sales_analysis.sql` : requêtes SQL permettant d’explorer les ventes, calculer des KPIs (commandes, clients, CA, coûts, quantités) et analyser les catégories de produits.
- `5-sales_sample.csv` : échantillon de 2 000 lignes extrait du dataset complet afin de rester compatible avec GitHub.

⚠️ Le dataset complet (~50 Mo) n’est pas versionné pour des raisons de taille. Cet échantillon est fourni pour la démonstration, mais toutes les requêtes du script SQL sont applicables à l’intégralité du jeu de données.
