-- 0) Exploration rapide de la table
SELECT *
FROM sales.retail_sales_raw
LIMIT 100;

-- Vérif basique des colonnes clés (comptages distincts)
SELECT
  COUNT(DISTINCT orders_id)    AS nb_orders,
  COUNT(DISTINCT products_id)  AS nb_products,
  COUNT(DISTINCT customers_id) AS nb_customers
FROM sales.retail_sales_raw;

-- 1) AGRÉGATIONS GLOBALES
-- Objectif : totaux commandes / produits / clients / CA / coût / quantités

-- 1.1) KPIs globaux
SELECT
  COUNT(DISTINCT orders_id)    AS nb_orders,
  COUNT(DISTINCT products_id)  AS nb_products,
  COUNT(DISTINCT customers_id) AS nb_customers,
  SUM(turnover)                AS sum_turnover,
  SUM(purchase_cost)           AS sum_purchase_cost,
  SUM(qty)                     AS sum_qty
FROM sales.retail_sales_raw;


-- 1.2) KPIs par grande catégorie (category_1)
SELECT
  category_1,
  COUNT(DISTINCT orders_id)    AS nb_orders,
  COUNT(DISTINCT products_id)  AS nb_products,
  COUNT(DISTINCT customers_id) AS nb_customers,
  SUM(turnover)                AS sum_turnover,
  SUM(purchase_cost)           AS sum_purchase_cost,
  SUM(qty)                     AS sum_qty
FROM sales.retail_sales_raw
GROUP BY category_1;

-- 1.3) Classement des category_1 par CA décroissant
SELECT
  category_1,
  COUNT(DISTINCT orders_id)    AS nb_orders,
  COUNT(DISTINCT products_id)  AS nb_products,
  COUNT(DISTINCT customers_id) AS nb_customers,
  SUM(turnover)                AS sum_turnover,
  SUM(purchase_cost)           AS sum_purchase_cost,
  SUM(qty)                     AS sum_qty
FROM sales.retail_sales_raw
GROUP BY category_1
ORDER BY sum_turnover DESC;

-- 2) APPROFONDISSEMENT CATÉGORIEL
-- Objectif : identifier les sous-catégories (category_2 / category_3), les plus contributrices dans la category_1 la plus élevée en CA et remplacement de 'Bébé & Enfant' si besoin selon le top category_1.

-- 2.1) Top sous-catégories (category_2 / category_3) en CA
SELECT
  category_2,
  category_3,
  SUM(turnover) AS sum_turnover
FROM sales.retail_sales_raw
WHERE category_1 = 'Bébé & Enfant'
GROUP BY category_2, category_3
ORDER BY sum_turnover DESC;

-- 2.2) Volume commandes & clients par (category_2, category_3)
SELECT
  category_2,
  category_3,
  COUNT(DISTINCT orders_id)    AS nb_orders,
  COUNT(DISTINCT customers_id) AS nb_customers
FROM sales.retail_sales_raw
WHERE category_1 = 'Bébé & Enfant'
GROUP BY category_2, category_3
ORDER BY nb_orders DESC;

-- 2.3.) Nombre de commandes par client (orders per customer)
SELECT
  category_2,
  category_3,
  COUNT(DISTINCT orders_id)    AS nb_orders,
  COUNT(DISTINCT customers_id) AS nb_customers,
  SAFE_DIVIDE(COUNT(DISTINCT orders_id),
              COUNT(DISTINCT customers_id)) AS nb_orders_per_customer
FROM sales.retail_sales_raw
WHERE category_1 = 'Bébé & Enfant'
GROUP BY category_2, category_3
ORDER BY nb_orders_per_customer DESC;

-- 2.4) Prix d’achat moyen & nb de produits distincts par sous-catégorie
SELECT
  category_2,
  category_3,
  COUNT(DISTINCT products_id) AS nb_products,
  AVG(purchase_cost)         AS avg_purchase_cost
FROM sales.retail_sales_raw
WHERE category_1 = 'Bébé & Enfant'
GROUP BY category_2, category_3
ORDER BY avg_purchase_cost DESC;
