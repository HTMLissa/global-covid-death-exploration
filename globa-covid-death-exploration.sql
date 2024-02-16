-- Looking at total cases vs. total deaths
-- Shows likelihood of dying if you contract covid per country

SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  (total_deaths/total_cases) * 100 AS death_percentage
FROM 
  `covid-deaths-414419.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL
ORDER BY
  1,2;

-- Looking at total cases vs. population
-- Shows what percentage of population has gotten covid

SELECT 
  location, 
  date, 
  total_cases, 
  population, 
  (total_cases/population) * 100 AS case_percentage
FROM 
  `covid-deaths-414419.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL
ORDER BY
  1,2;

-- Exploring infection rates by country

SELECT 
  location, 
  population, 
  MAX(total_cases) AS highest_infection_count, 
  MAX((total_cases/population)) * 100 AS case_percentage
FROM 
  `covid-deaths-414419.covid_data.covid_deaths`
WHERE
  continent IS NOT NULL
GROUP BY
  location,
  population
ORDER BY
  case_percentage DESC;

-- Exploring continents with highest death count per population

SELECT 
  location,
  MAX(total_deaths) AS total_death_count
FROM 
  `covid-deaths-414419.covid_data.covid_deaths`
WHERE
  continent IS NULL
GROUP BY
  location
ORDER BY
  total_death_count DESC;

-- Exploring countries with highest death count per population

SELECT 
  location,
  MAX(total_deaths) AS total_death_count
FROM 
  `covid-deaths-414419.covid_data.covid_deaths`
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  total_death_count DESC;

-- Exploring global numbers over time

SELECT 
  date, 
  SUM(new_cases) AS total_cases, 
  SUM(new_deaths) AS total_deaths, 
  IFNULL(SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100, 0) AS death_percentage -- Handle division by zero
FROM 
  `covid-deaths-414419.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL
GROUP BY 
  date
ORDER BY
  1,2;

-- Exploring total deaths across the globe

SELECT 
  SUM(new_cases) AS total_cases, 
  SUM(new_deaths) AS total_deaths, 
  IFNULL(SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100, 0) AS death_percentage -- Handle division by zero
FROM 
  `covid-deaths-414419.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL
ORDER BY
  1,2;

-- Exploring total vaccinations vs. population

SELECT 
  continent,
  location, 
  date, 
  population,
  new_vaccinations,
  SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_vaccinated,

FROM 
  `covid-deaths-414419.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL
ORDER BY
  2,3;

-- Creating CTE 

WITH 
  pop_vs_vac
AS
  (
    SELECT 
      continent,
      location, 
      date, 
      population,
      new_vaccinations,
      SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_vaccinated,
    FROM 
      `covid-deaths-414419.covid_data.covid_deaths` 
    WHERE
      continent IS NOT NULL
  )

SELECT
  *,
  (rolling_people_vaccinated / population) * 100 AS rolling_percent_vaccinated
FROM
  pop_vs_vac;

-- Creating View to store data for later visualizations

CREATE VIEW covid-deaths-414419.covid_data.percent_population_vaccinated AS
  SELECT 
      continent,
      location, 
      date, 
      population,
      new_vaccinations,
      SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS rolling_people_vaccinated,
    FROM 
      `covid-deaths-414419.covid_data.covid_deaths` 
    WHERE
      continent IS NOT NULL
