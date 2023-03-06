select * 
from PortfolioProject..CovidDeaths
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in Nigeria.

select continent, location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as Deathpercentage  
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2

--looking at total_cases vs Population 
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases / population)*100 as percentPopulationInfected  
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2

--looking at countries with highest infection rate compared to population 

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases / population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
group by location, population  
order by PercentPopulationInfected desc

--showing countries with highest death count per population 

select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location, population  
order by TotalDeathCount desc

--lets break down by continent
--SHOWING CONTINENTS WITH THE HIGHEST DEATHCOUNT

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent 
order by TotalDeathCount desc

--GLOBAL NUMBERS 

select  date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDedaths
, sum(cast(new_deaths as int)) / sum(new_cases) *100 as DeathPrecentage   
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2


--USING CTE 
with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinations)
as
(
--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int))  over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinations/population)*100
from PopvsVac


--USING TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinations numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations ))  over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select*, (rollingpeoplevaccinations/population) *100
from #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION 
create view percentpopulationvaccinations as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations ))  over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

