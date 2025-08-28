- 0) Normalisation des dates depuis les CSV bruts (formats mixtes)

WITH shipments_parsed AS (
  SELECT
    parcel_id,
    parcel_tracking,
    transporter,
    priority,
    -- Normalisation (YYYY-MM-DD / DD/MM/YYYY / "Month DD, YYYY")
    COALESCE(
      SAFE.PARSE_DATE('%Y-%m-%d', date_purchase),
      SAFE.PARSE_DATE('%d/%m/%Y', date_purchase),
      SAFE.PARSE_DATE('%B %e, %Y', date_purchase)
    ) AS date_purchase,
    COALESCE(
      SAFE.PARSE_DATE('%Y-%m-%d', date_shipping),
      SAFE.PARSE_DATE('%d/%m/%Y', date_shipping),
      SAFE.PARSE_DATE('%B %e, %Y', date_shipping)
    ) AS date_shipping,
    COALESCE(
      SAFE.PARSE_DATE('%Y-%m-%d', date_delivery),
      SAFE.PARSE_DATE('%d/%m/%Y', date_delivery),
      SAFE.PARSE_DATE('%B %e, %Y', date_delivery)
    ) AS date_delivery,
    COALESCE(
      SAFE.PARSE_DATE('%Y-%m-%d', date_cancelled),
      SAFE.PARSE_DATE('%d/%m/%Y', date_cancelled),
      SAFE.PARSE_DATE('%B %e, %Y', date_cancelled)
    ) AS date_cancelled
  FROM logistics.shipments_raw
),

shipments_enriched AS (
  SELECT
    parcel_id,
    parcel_tracking,
    transporter,
    priority,
    date_purchase,
    date_shipping,
    date_delivery,
    date_cancelled,

    EXTRACT(MONTH FROM date_purchase) AS month_purchase,

    CASE
      WHEN date_cancelled IS NOT NULL THEN 'Cancelled'
      WHEN date_shipping  IS NULL     THEN 'In Progress'
      WHEN date_delivery  IS NULL     THEN 'In Transit'
      ELSE 'Delivered'
    END AS status,

    DATE_DIFF(date_shipping, date_purchase, DAY) AS shipping_time,
    DATE_DIFF(date_delivery, date_shipping, DAY) AS delivery_time,
    DATE_DIFF(date_delivery, date_purchase, DAY) AS total_time,

    CASE
      WHEN date_delivery IS NULL THEN NULL
      WHEN DATE_DIFF(date_delivery, date_purchase, DAY) > 5 THEN 1
      ELSE 0
    END AS delay
  FROM shipments_parsed
),

shipments_products AS (
  SELECT
    parcel_id,
    model_name,
    qty
  FROM logistics.shipments_products_raw
)


-- 1) Enrichissement du csv colis → 3-shipments_enriched.csv

SELECT * FROM shipments_enriched
ORDER BY parcel_id;

-- 2) Statistiques globales → 3-shipments_overview.csv

SELECT
  COUNT(*)                                           AS nb_parcel,
  ROUND(AVG(shipping_time), 2)                       AS shipping_time,
  ROUND(AVG(delivery_time), 2)                       AS delivery_time,
  ROUND(AVG(total_time),   2)                        AS total_time,
  ROUND(AVG(CAST(delay AS FLOAT64)), 2)              AS delay_rate
FROM shipments_enriched;

-- 3)Par transporteur OUT → 3-shipments_by_carrier.csv

SELECT
  transporter,
  COUNT(*)                     AS nb_parcel,
  ROUND(AVG(shipping_time), 2) AS shipping_time,
  ROUND(AVG(delivery_time), 2) AS delivery_time,
  ROUND(AVG(total_time),   2)  AS total_time,
  ROUND(AVG(CAST(delay AS FLOAT64)), 2) AS delay_rate
FROM shipments_enriched
GROUP BY transporter
ORDER BY transporter;

-- 4) Par priorité → 3-shipments_by_priority.csv

SELECT
  priority,
  COUNT(*)                     AS nb_parcel,
  ROUND(AVG(shipping_time), 2) AS shipping_time,
  ROUND(AVG(delivery_time), 2) AS delivery_time,
  ROUND(AVG(total_time),   2)  AS total_time,
  ROUND(AVG(CAST(delay AS FLOAT64)), 2) AS delay_rate
FROM shipments_enriched
GROUP BY priority
ORDER BY priority;

-- 5) Par mois d’achat → 3-shipments_by_month.csv

SELECT
  month_purchase,
  COUNT(*)                     AS nb_parcel,
  ROUND(AVG(shipping_time), 2) AS shipping_time,
  ROUND(AVG(delivery_time), 2) AS delivery_time,
  ROUND(AVG(total_time),   2)  AS total_time
FROM shipments_enriched
GROUP BY month_purchase
ORDER BY month_purchase;

-- 6) colis livrés en retard > 5j OUT → 3-shipments_delays.csv)

SELECT
  parcel_id,
  parcel_tracking,
  transporter,
  priority,
  date_purchase,
  date_shipping,
  date_delivery,
  total_time,
  1 AS delay
FROM shipments_enriched
WHERE date_delivery IS NOT NULL
  AND total_time > 5
ORDER BY total_time DESC;

-- 7) jointure colis + produits → 3-shipments_with_products.csv

SELECT
  e.parcel_id,
  e.parcel_tracking,
  e.transporter,
  e.priority,
  e.date_purchase,
  e.date_shipping,
  e.date_delivery,
  e.date_cancelled,
  p.model_name,
  p.qty
FROM shipments_enriched AS e
LEFT JOIN shipments_products AS p
  USING (parcel_id)
ORDER BY e.parcel_id;
