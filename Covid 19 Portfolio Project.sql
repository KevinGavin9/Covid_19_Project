/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From covid_deaths
Where continent is not null;

-- Select Data that I am Starting With

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
Where continent is not null;

-- Total Cases vs Total Deaths
-- Mortality Rate in each Country

SELECT location, date, total_cases, total_deaths, 
(total_deaths::numeric/total_cases::numeric)*100 AS mortality_rate
FROM covid_deaths

-- Mortality Rate in Ireland

SELECT location, date, total_cases, total_deaths, 
(total_deaths::float/total_cases::float)*100 AS mortality_rate
FROM covid_deaths
WHERE location LIKE 'Ireland';

--Total Cases vs Population 
-- Shows what Percentage of Population Infected with Covid

SELECT location, date, population, total_cases, 
(total_cases::float/population::float)*100 AS cases_vs_population
FROM covid_deaths
WHERE location LIKE 'Ireland'
ORDER BY total_cases ASC;

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_rate,
MAX((total_cases::float/population::float))*100 AS percentage_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percentage_population_infected DESC;

-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;

-- Showing Contintents with the Highest Death Count per Population

SELECT location, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC; 

-- Global Mortality Rate

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as numeric)) as total_deaths, 
SUM(cast(new_deaths as numeric))/SUM(New_Cases)*100 as mortality_percentage
From covid_deaths
where continent is not null;

-- Total Population vs Total Vaccinations
-- Shows Percentage of Population that has Recieved at a Covid Vaccine

SELECT  deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.total_vaccinations
FROM covid_deaths deaths
JOIN covid_vaccinations vaccs
ON deaths.location = vaccs.location
WHERE deaths.continent is not null
AND deaths.date = vaccs.date
ORDER BY 2,3;

-- Rolling Total of each Country's Population that has Recieved a Covid Vaccine

SELECT  deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(vaccs.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Rolling_Total_Vaccinations
FROM covid_deaths deaths
JOIN covid_vaccinations vaccs
ON deaths.location = vaccs.location
AND deaths.date = vaccs.date
WHERE deaths.continent is not null
ORDER BY 2,3;


-- Using CTE to Perform Calculation on Partition By in Previous Query. 
-- Specifcally showing a Rolling Percentage of Population that has recieved a Covid Vaccine

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Total_Vaccinations)
AS
(
	SELECT  deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(vaccs.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Rolling_Total_Vaccinations
FROM covid_deaths deaths
JOIN covid_vaccinations vaccs
ON deaths.location = vaccs.location
AND deaths.date = vaccs.date
WHERE deaths.continent is not null
)
SELECT *, (Rolling_Total_Vaccinations/population)*100 AS Rolling_Percentage_Total_Vaccinations
FROM PopvsVac;

-- Creating View to Store Data for Later Visualizations

CREATE VIEW Rolling_Vaccination_Rates AS
SELECT  deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(vaccs.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Rolling_Total_Vaccinations
FROM covid_deaths deaths
JOIN covid_vaccinations vaccs
ON deaths.location = vaccs.location
AND deaths.date = vaccs.date
WHERE deaths.continent is not null;

CREATE VIEW Mortality_Rates AS 
SELECT location, date, total_cases, total_deaths, 
(total_deaths::float/total_cases::float) AS mortality_percentage
FROM covid_deaths;

CREATE VIEW Ireland_Mortality_Rates AS 
SELECT location, date, total_cases, total_deaths, 
(total_deaths::float/total_cases::float) AS mortality_percentage
FROM covid_deaths
WHERE location LIKE 'Ireland';

CREATE VIEW Cases_vs_Population_Global AS
SELECT location, date, population, total_cases, 
(total_cases::float/population::float)*100 AS cases_vs_population
FROM covid_deaths
ORDER BY total_cases ASC;

CREATE VIEW Cases_vs_Population_Ireland AS
SELECT location, date, population, total_cases, 
(total_cases::float/population::float)*100 AS cases_vs_population
FROM covid_deaths
WHERE location LIKE 'Ireland'
ORDER BY total_cases ASC;

CREATE VIEW Countries_Infection_Rates AS
SELECT location, population, MAX(total_cases) AS highest_infection_rate,
MAX((total_cases::float/population::float))*100 AS percentage_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percentage_population_infected DESC;

CREATE VIEW countries_total_deaths AS
SELECT location, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;

CREATE VIEW continent_death_count AS
SELECT location, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC;

CREATE VIEW population_vs_vaccinations AS 
SELECT  deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.total_vaccinations
FROM covid_deaths deaths
JOIN covid_vaccinations vaccs
ON deaths.location = vaccs.location
WHERE deaths.continent is not null
AND deaths.date = vaccs.date
ORDER BY 2,3;