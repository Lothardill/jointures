-- 1) Exploration de la table brute
SELECT * 
FROM funnel.sales_funnel_raw;

-- Vérification de la clé primaire (company)
SELECT 
  company,
  COUNT(*) AS nb
FROM funnel.sales_funnel_raw
GROUP BY company
HAVING nb > 1
ORDER BY nb DESC;

-- 2) Enrichissement : ajout des colonnes de conversion et de temps
CREATE OR REPLACE TABLE funnel.sales_funnel_kpi AS
SELECT
  -- Identifiant
  company,
  sector,
  priority,

  -- Dates
  date_lead,
  date_opportunity,
  date_customer,
  date_lost,

  -- Étape actuelle du funnel
  CASE
    WHEN date_lost IS NOT NULL THEN "4 - Lost"
    WHEN date_customer IS NOT NULL THEN "3 - Customer"
    WHEN date_opportunity IS NOT NULL THEN "2 - Opportunity"
    WHEN date_lead IS NOT NULL THEN "1 - Lead"
    ELSE NULL
  END AS deal_stage,

  -- Indicateurs de conversion
  CASE
    WHEN date_lost IS NOT NULL THEN 0
    WHEN date_customer IS NOT NULL THEN 1
    ELSE NULL
  END AS lead2customer,

  CASE
    WHEN date_lost IS NOT NULL THEN 0
    WHEN date_opportunity IS NOT NULL THEN 1
    ELSE NULL
  END AS lead2opportunity,

  CASE
    WHEN date_lost IS NOT NULL AND date_opportunity IS NOT NULL THEN 0
    WHEN date_customer IS NOT NULL THEN 1
    ELSE NULL
  END AS opportunity2customer,

  -- Délais de conversion
  DATE_DIFF(date_customer, date_lead, DAY) AS lead2customer_time,
  DATE_DIFF(date_opportunity, date_lead, DAY) AS lead2opportunity_time,
  DATE_DIFF(date_customer, date_opportunity, DAY) AS opportunity2customer_time

FROM funnel.sales_funnel_raw;


-- 3) Agrégats : Vue globale
SELECT
  COUNT(*) AS nb_prospects,
  COUNT(date_customer) AS nb_clients,
  ROUND(AVG(lead2customer)*100,1) AS taux_lead2customer,
  ROUND(AVG(lead2opportunity)*100,1) AS taux_lead2opportunity,
  ROUND(AVG(opportunity2customer)*100,1) AS taux_opportunity2customer,
  ROUND(AVG(lead2customer_time),2) AS delai_lead2customer,
  ROUND(AVG(lead2opportunity_time),2) AS delai_lead2opportunity,
  ROUND(AVG(opportunity2customer_time),2) AS delai_opportunity2customer
FROM funnel.sales_funnel_kpi;


-- 4) Agrégats : Par priorité
SELECT
  priority,
  COUNT(*) AS nb_prospects,
  COUNT(date_customer) AS nb_clients,
  ROUND(AVG(lead2customer)*100,1) AS taux_lead2customer,
  ROUND(AVG(lead2opportunity)*100,1) AS taux_lead2opportunity,
  ROUND(AVG(opportunity2customer)*100,1) AS taux_opportunity2customer,
  ROUND(AVG(lead2customer_time),2) AS delai_lead2customer,
  ROUND(AVG(lead2opportunity_time),2) AS delai_lead2opportunity,
  ROUND(AVG(opportunity2customer_time),2) AS delai_opportunity2customer
FROM funnel.sales_funnel_kpi
GROUP BY priority
ORDER BY priority;


-- 5) Agrégats : Par mois (basé sur la date de lead)
SELECT
  EXTRACT(MONTH FROM date_lead) AS mois_lead,
  COUNT(*) AS nb_prospects,
  COUNT(date_customer) AS nb_clients,
  ROUND(AVG(lead2customer)*100,1) AS taux_lead2customer,
  ROUND(AVG(lead2opportunity)*100,1) AS taux_lead2opportunity,
  ROUND(AVG(opportunity2customer)*100,1) AS taux_opportunity2customer,
  ROUND(AVG(lead2customer_time),2) AS delai_lead2customer,
  ROUND(AVG(lead2opportunity_time),2) AS delai_lead2opportunity,
  ROUND(AVG(opportunity2customer_time),2) AS delai_opportunity2customer
FROM funnel.sales_funnel_kpi
GROUP BY mois_lead
ORDER BY mois_lead;
