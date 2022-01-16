USE Portfolio

select continent, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths]
order by 1,2

-- Total Cases vs Total Deaths in US
-- Likelihood of fatality if contract covid 

select continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent like '%states%' 
order by date desc


--Total cases vs population in US
-- % of population gotten covid

select continent, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent like '%states%'
order by 1,2



-- Countires w/ higest infection rate vs population

select continent, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as 
	PercentPopulationInfected
From [dbo].[CovidDeaths]
Group by continent, population
order by PercentPopulationInfected desc


-- Countries w/ highest deaths Count per Population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is null
Group by continent
order by TotalDeathCount desc


-- continet w/ highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc


---global numbers by date
select SUM(total_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(total_cases)*100 as DeathPercentage 
from [dbo].[CovidDeaths]
where continent is not null
--Group by date
order by 1,2
-- cast as int because new_death column is nvarchar

--Total population vs vaccination

Set ansi_warnings off
select de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) 
	OVER (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] de
join
[dbo].[CovidVacs] vc
	On de.location = vc.location 
	and de.date = vc.date
where de.continent is not null
order by 2, 3 -- ordered by location and date
-- *Had to cast nvarchar to bigint as the numbers overflowed
-- *partition does a rolling count, adds first row of new vacination + rolling people ~ the total is on the next rolling people line, 
    -- if there isnt new data (nulls/zeros) on next line of new vacs, the rolling people #'s will stay the same until 
    -- more data is added to new vacs

-- USE CTE for above Script, in order to include the equation for percentage using the new column name
 with POPvsVac (contintent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as 
 (select de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) 
	OVER (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated -- <-new column name
from [dbo].[CovidDeaths] de
join
[dbo].[CovidVacs] vc
	On de.location = vc.location 
	and de.date = vc.date
where de.continent is not null
--order by 2, 3 - cannot use order by in a CTE
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from POPvsVac


--Temp table

Drop Table if Exists #PercentPopulationVaccinted

Create Table #PercentPopulationVaccinted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinted
select de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
	SUM(CAST(new_vaccinations as bigint)) 
	OVER (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] de
join
[dbo].[CovidVacs] vc
	On de.location = vc.location 
	and de.date = vc.date
where de.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinted


-------------------------------------------------
select continent, location
from [dbo].[CovidDeaths]
Where continent is not null 

-- not null is to get rid of things that say world, international, etc (in contient column)
-- is null is to show proper continents, that are named in location

select top 10 *
from [dbo].[CovidVacs]





