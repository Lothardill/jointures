-- 1) INNER JOIN produits et segments
-- Récupére pdt_name et pdt_segment
SELECT
  p.pdt_name,
  sgt.pdt_segment
FROM catalog.products AS p
INNER JOIN catalog.products_segments AS sgt
  ON p.products_id = sgt.products_id;


-- 2) INNER JOIN produits ↔ stock
-- Ajoute les infos de stock aux détails produit
SELECT
  -- product
  p.products_id,
  p.pdt_name,
  p.products_status,
  p.categories_id,
  p.promo_id,
  -- stock
  st.stock,
  st.stock_forecast
FROM catalog.products AS p
INNER JOIN catalog.stocks AS st
  ON p.products_id = st.pdt_id;


-- 3) LEFT JOIN produits ↔ promotions
-- Garde tous les produits même sans promotion
SELECT
  p.products_id,
  p.pdt_name,
  pr.promo_name,
  pr.promo_pourcent
FROM catalog.products AS p
LEFT JOIN catalog.promotions AS pr
  ON p.promo_id = pr.promo_id;


-- 4) INNER JOIN produits ↔ prix (USING si clé identique)
-- Ajoute les infos de prix
SELECT
  p.products_id,
  p.pdt_name,
  p.products_status,
  p.categories_id,
  p.promo_id,
  prc.pd_cat,
  prc.ps_cat
FROM catalog.products AS p
INNER JOIN catalog.prices AS prc
  USING (products_id);


-- 5) INNER JOIN produits ↔ catégories (USING si clé identique)
-- Récupére l’arborescence catégorie
SELECT
  p.products_id,
  p.pdt_name,
  p.categories_id,
  c.category_1,
  c.category_2,
  c.category_3
FROM catalog.products AS p
INNER JOIN catalog.categories AS c
  USING (categories_id);


-- 6) LEFT JOIN produits ↔ ventes 3 derniers mois
-- Inclut tous les produits, qty=0 si aucune vente
SELECT
  p.products_id,
  p.pdt_name,
  IFNULL(s.qty, 0) AS qty
FROM catalog.products AS p
LEFT JOIN catalog.sales_last3months AS s
  ON p.products_id = s.pdt_id;


-- 7) Variante RIGHT JOIN (même résultat logique que 6)
SELECT
  p.products_id,
  p.pdt_name,
  s.qty
FROM catalog.sales_last3months AS s
RIGHT JOIN catalog.products AS p
  ON p.products_id = s.pdt_id;
