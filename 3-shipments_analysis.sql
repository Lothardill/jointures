-- 1) COLIS ENRICHIS → 3-shipments_overview.csv
--    Ajoute statut + temps (jours) + mois d’achat + flag retard
WITH base AS (
  SELECT
    parcel_id,
    parcel_tracking,
    transporter,
    priority,
    date_purchase,
    date_shipping,
    date_delivery,
    date_cancelled
  FROM logistics.shipments
)
SELECT
  parcel_id,
  parcel_tracking,
  transporter,
  priority,
  date_purchase,
  date_shipping,
  date_delivery,
  date_cancelled,

  -- Mois d’achat (numérique 1...12)
  EXTRACT(MONTH FROM date_purchase) AS month_purchase,

  -- Statut
  CASE
    WHEN date_cancelled IS NOT NULL THEN 'Cancelled'
    WHEN date_shipping  IS NULL     THEN 'In Progress'
    WHEN date_delivery  IS NULL     THEN 'In Transit'
    ELSE 'Delivered'
  END AS status,

  -- KPI temps (en jours)
  DATE_DIFF(date_shipping, date_purchase, DAY) AS shipping_time,
  DATE_DIFF(date_delivery, date_shipping, DAY) AS delivery_time,
  DATE_DIFF(date_delivery, date_purchase, DAY) AS total_time,

  -- Retard (> 5 jours entre achat et livraison). NULL si pas livré.
  CASE
    WHEN date_delivery IS NULL THEN NULL
    WHEN DATE_DIFF(date_delivery, date_purchase, DAY) > 5 THEN 1
    ELSE 0
  END AS delay
FROM base
ORDER BY parcel_id;

-- 2) AGRÉGATS GLOBAUX → 3-shipments_overview.csv

WITH enriched AS (
  SELECT
    parcel_id,
    DATE_DIFF(date_shipping, date_purchase, DAY) AS shipping_time,
    DATE_DIFF(date_delivery, date_shipping, DAY) AS delivery_time,
    DATE_DIFF(date_delivery, date_purchase, DAY) AS total_time,
    CASE
      WHEN date_delivery IS NULL THEN NULL
      WHEN DATE_DIFF(date_delivery, date_purchase, DAY) > 5 THEN 1
      ELSE 0
    END AS delay
  FROM logistics.shipments
)
SELECT
  COUNT(*)                                           AS nb_parcel,
  ROUND(AVG(shipping_time), 2)                       AS shipping_time,
  ROUND(AVG(delivery_time), 2)                       AS delivery_time,
  ROUND(AVG(total_time),   2)                        AS total_time,
  ROUND(AVG(CAST(delay AS FLOAT64)), 2)              AS delay_rate
FROM enriched;

-- 3) AGRÉGATS PAR TRANSPORTEUR → 3-shipments_by_carrier.csv

WITH enriched AS (
  SELECT
    parcel_id,
    transporter,
    DATE_DIFF(date_shipping, date_purchase, DAY) AS shipping_time,
    DATE_DIFF(date_delivery, date_shipping, DAY) AS delivery_time,
    DATE_DIFF(date_delivery, date_purchase, DAY) AS total_time,
    CASE
      WHEN date_delivery IS NULL THEN NULL
      WHEN DATE_DIFF(date_delivery, date_purchase, DAY) > 5 THEN 1
      ELSE 0
    END AS delay
  FROM logistics.shipments
)
SELECT
  transporter,
  COUNT(*)                                          AS nb_parcel,
  ROUND(AVG(shipping_time), 2)                      AS shipping_time,
  ROUND(AVG(delivery_time), 2)                      AS delivery_time,
  ROUND(AVG(total_time),   2)                       AS total_time,
  ROUND(AVG(CAST(delay AS FLOAT64)), 2)             AS delay_rate
FROM enriched
GROUP BY transporter
ORDER BY transporter;

-- 4) AGRÉGATS PAR PRIORITÉ → 3-shipments_by_priority.csv

WITH enriched AS (
  SELECT
    parcel_id,
    priority,
    DATE_DIFF(date_shipping, date_purchase, DAY) AS shipping_time,
    DATE_DIFF(date_delivery, date_shipping, DAY) AS delivery_time,
    DATE_DIFF(date_delivery, date_purchase, DAY) AS total_time,
    CASE
      WHEN date_delivery IS NULL THEN NULL
      WHEN DATE_DIFF(date_delivery, date_purchase, DAY) > 5 THEN 1
      ELSE 0
    END AS delay
  FROM logistics.shipments
)
SELECT
  priority,
  COUNT(*)                                          AS nb_parcel,
  ROUND(AVG(shipping_time), 2)                      AS shipping_time,
  ROUND(AVG(delivery_time), 2)                      AS delivery_time,
  ROUND(AVG(total_time),   2)                       AS total_time,
  ROUND(AVG(CAST(delay AS FLOAT64)), 2)             AS delay_rate
FROM enriched
GROUP BY priority
ORDER BY priority;

-- 5) AGRÉGATS PAR MOIS D’ACHAT → 3-shipments_by_month.csv

WITH enriched AS (
  SELECT
    EXTRACT(MONTH FROM date_purchase) AS month_purchase,
    DATE_DIFF(date_shipping, date_purchase, DAY) AS shipping_time,
    DATE_DIFF(date_delivery, date_shipping, DAY) AS delivery_time,
    DATE_DIFF(date_delivery, date_purchase, DAY) AS total_time
  FROM logistics.shipments
)
SELECT
  month_purchase,
  COUNT(*)                     AS nb_parcel,
  ROUND(AVG(shipping_time), 2) AS shipping_time,
  ROUND(AVG(delivery_time), 2) AS delivery_time,
  ROUND(AVG(total_time),   2)  AS total_time
FROM enriched
GROUP BY month_purchase
ORDER BY month_purchase;

-- 6) COLIS + PRODUITS 
--    (niveau ligne-produit dans le colis)

SELECT
  s.parcel_id,
  s.parcel_tracking,
  s.transporter,
  s.priority,
  s.date_purchase,
  s.date_shipping,
  s.date_delivery,
  s.date_cancelled,
  p.model_name,
  p.qty
FROM logistics.shipments AS s
LEFT JOIN logistics.shipments_products AS p
  USING (parcel_id)
ORDER BY s.parcel_id;

-- 7) FOCUS RETARDS → 3-shipments_delays.csv
--    Tous les colis livrés avec total_time > 5 jours

SELECT
  parcel_id,
  parcel_tracking,
  transporter,
  priority,
  date_purchase,
  date_shipping,
  date_delivery,
  DATE_DIFF(date_delivery, date_purchase, DAY) AS total_time,
  1 AS delay
FROM logistics.shipments
WHERE date_delivery IS NOT NULL
  AND DATE_DIFF(date_delivery, date_purchase, DAY) > 5
ORDER BY total_time DESC;
