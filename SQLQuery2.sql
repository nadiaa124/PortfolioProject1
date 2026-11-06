
Select *
From PortfolioProject ..CovidDeaths
Where continent is not null

-- select data that we're going to use:
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject ..CovidDeaths
Where continent is not null
order by 1,2

-- looking at total cases VS total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject ..CovidDeaths
Where location like '%Egypt%' and continent is not null
Order by 1,2


--looking at the total cases VS population
Select location, date, total_cases, population, (total_cases/population)*100 as total_cases_percentage
From PortfolioProject ..CovidDeaths
Where continent is not null
order by 5 desc

--looking at countries with highest infection rate compared to population
Select location, max(total_cases) as Highest_infection_count, population, max((total_cases/population)*100) as total_cases_percentage
From PortfolioProject ..CovidDeaths
Where continent is not null
Group by location, population
order by total_cases_percentage desc




-- showing the countries with the highest death count per population
Select location, max(cast(total_deaths as int)) as Highest_death_count
From PortfolioProject ..CovidDeaths
Where continent is not null
Group by location, population
order by Highest_death_count desc

Select location, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject ..CovidDeaths
Where continent is null
Group by location
order by total_death_count desc


-- BREAK TGINGS DOWN BY CONTINENT
-- showing the continents with the highesr death counts
Select continent, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject ..CovidDeaths
Where continent is null
Group by continent
order by total_death_count desc

-- GLOBAL NUMBERS
Select  date, Sum(new_cases) as new_cases, Sum(cast(new_deaths as int)) as new_deaths,
((Sum(Cast(new_deaths as int))/Sum(new_cases))*100) as death_percentage
From PortfolioProject ..CovidDeaths
Where continent is not null
Group by date
Order by new_cases desc

Select  Sum(new_cases) as new_cases, Sum(cast(new_deaths as int)) as new_deaths,
((Sum(Cast(new_deaths as int))/Sum(new_cases))*100) as death_percentage
From PortfolioProject ..CovidDeaths
Where continent is not null
Order by 1,2


-- fixing dublication issue
WITH RowCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY location, date 
            ORDER BY (SELECT NULL) -- بيحدد طريقة ترقيم الصفوف المتطابقة
        ) AS row_num
    FROM PortfolioProject..CovidDeaths
)
DELETE FROM RowCTE
WHERE row_num > 1;


-- looking at total population VS vaccination
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
Sum(Cast(vacc.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
ON death.location = vacc.location
And death.date = vacc.date
Where death.continent is not null
Order by 2,3

-- Use CTE (Common Table Expression)
With PopVac (Continent, location, date, population, new_vaccination, rolling_people_vaccinated)
as (
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
Sum(Cast(vacc.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
ON death.location = vacc.location
And death.date = vacc.date
Where death.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100 as percentage
From popVac
Order by 2,3


-- TEMP TABLE
DROP Table if exists #PercentPopulationVccinated
CREATE TABLE #PercentPopulationVccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVccinated
Select 
death.continent, 
death.location, 
death.date, 
death.population, 
vacc.new_vaccinations,
Sum(Cast(vacc.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
ON death.location = vacc.location
And death.date = vacc.date
--Where death.continent is not null
--Order by 2,3

Select *, (rolling_people_vaccinated/population)*100 as percentage
From #PercentPopulationVccinated


-- Creating view to store data for later visulaizations
Create View PercentPopulationVccinated as 
Select 
death.continent, 
death.location, 
death.date, 
death.population, 
vacc.new_vaccinations,
Sum(Cast(vacc.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
ON death.location = vacc.location
And death.date = vacc.date
Where death.continent is not null
--Order by 2,3