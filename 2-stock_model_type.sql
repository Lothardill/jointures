-- 1. Vérifier que product_id est bien une clé primaire dans la table stock_catalog
SELECT
  ### Key ###
  product_id
  ###########
  ,COUNT(*) AS nb
FROM inventory.stock_catalog
GROUP BY product_id
HAVING nb >= 2
ORDER BY nb DESC;


-- 2. Vérifier que la combinaison model, color, size est une clé primaire dans la table stock_raw
SELECT
  ### Key ###
  model AS product_model,
  color AS product_color,
  size AS product_size
  ###########
  ,COUNT(*) AS nb
FROM inventory.stock_raw
GROUP BY model, color, size
HAVING nb >= 2
ORDER BY nb DESC;


-- 3. Vérifier que model_type n’est jamais NULL dans la table stock_kpi
SELECT
  ### Key ###
  product_id
  ###########
  ,model_type
FROM inventory.stock_kpi
WHERE model_type IS NULL
ORDER BY product_id;


-- 4. Vérifier que product_id est bien une clé primaire dans la table sales_daily
SELECT
  ### Key ###
  product_id
  ###########
  ,COUNT(*) AS nb
FROM inventory.sales_daily
GROUP BY product_id
HAVING nb >= 2
ORDER BY nb DESC;


-- 5. Vérifier que product_name n’est jamais NULL dans la table stock_kpi
SELECT
  ### Key ###
  product_id
  ###########
  ,product_name
FROM inventory.stock_kpi
WHERE product_name IS NULL
ORDER BY product_id;


-- 6. Vérifier que stock_value est toujours positif, nul ou NULL dans la table stock_kpi
SELECT
  ### Key ###
  product_id
  ###########
  ,stock_value
FROM inventory.stock_kpi
WHERE stock_value < 0
ORDER BY product_id;
