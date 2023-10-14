select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select data we are going to use

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- total cases vs total deaths in a country
-- illustrates the likihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (TRY_CAST(total_deaths AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(total_cases AS NUMERIC(10, 2)), 0)) * 100.0 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%United Kingdom%'
and continent is not null
order by 1,2

--total cases vs population
--illustrate percentage of the population which got covid
select location, date, total_cases, population, (TRY_CAST(total_cases AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0)) * 100.0 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%United Kingdom%'
and continent is not null
order by 1,2

--countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount,  max((TRY_CAST(total_cases AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0))) * 100.0 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%United Kingdom%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- group by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%United Kingdom%'
Where continent is not null
group by continent
order by TotalDeathCount desc

--counties with highest death counts per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%United Kingdom%'
Where continent is not null
group by location
order by TotalDeathCount desc


-- illustrating contintents with the highest death count per population 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%United Kingdom%'
Where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers
SELECT date,
       SUM(new_cases) as Total_Cases,
       SUM(cast(new_deaths as int)) as Total_Deaths,
       CASE WHEN SUM(new_cases) <> 0
            THEN SUM(cast(new_deaths as int))/(SUM(new_cases)*100)
            ELSE 0  -- or any other appropriate value or action
       END as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- total population vs vaccination
-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, AggregatePeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CAST(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as AggregatePeopleVaccinated
-- (AggregatePeopleVaccinated/population)*100
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
on dea.location =vac.location
and dea.date =vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
select *, (AggregatePeopleVaccinated/population)*100 as PercentageVaccinated
from popvsVac

--TEMP Table

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
AggregatePeopleVaccinated numeric
)
insert into  #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CAST(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as AggregatePeopleVaccinated
-- (AggregatePeopleVaccinated/population)*100
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
on dea.location =vac.location
and dea.date =vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

select *, (AggregatePeopleVaccinated/population)*100 as PercentageVaccinated
from  #percentpopulationvaccinated


-- Creating view to store data for later visualization
CREATE VIEW dbo.PercePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS AggregatePeopleVaccinated
-- (AggregatePeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--order by 2,3


