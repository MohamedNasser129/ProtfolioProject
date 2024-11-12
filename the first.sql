select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4



--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


---------------------------------------------

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country 

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like  '%states%'
and  continent is not null

order by 1,2


--looking at total cases vs population 
--showing what percentage of population have gotten covid 

select location,date,population,total_cases, (total_cases/population)*100 as percentpopulationinfected
from PortfolioProject..CovidDeaths
where location like  '%states%'
order by 1,2


--looking at countries with highest infection rates compared to population	
 
select location,population,max(total_cases) HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like  '%states%'
group by  location,population
order by PercentPopulationInfected desc


--showing countries with Highest death count per population 

select location,population,max(cast(total_deaths as float)) HighestDeathCount, max((cast(total_deaths as float)/population))*100 as PercentPopulationDeath
from PortfolioProject..CovidDeaths
--where location like  '%states%'
group by  location,population
order by PercentPopulationDeath desc


select location,max(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like  '%states%'
where continent is not null
group by  location
order by TotalDeathCount desc	

----------------------------------------------------
--lets break things down by continent

select continent,max(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like  '%states%'
where continent is not null
group by  continent
order by TotalDeathCount desc	


select location,max(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like  '%states%'
where continent is  null
group by  location
order by TotalDeathCount desc	

-----------------------------------------------------------------

--showing continent with highest death count per population 

select continent,max(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like  '%states%'
where continent is not null
group by  continent
order by TotalDeathCount desc	

-------------------------------------------------------------
--Global numbers 

select sum(new_cases) as total_cases,sum(cast(new_deaths   as int)) as total_deaths,sum(cast(new_deaths   as int))/sum(new_cases) death_percentage
from PortfolioProject..CovidDeaths
--where location like  '%states%'
where  continent is not null
--group by date
order by 1,2

---------------------------------------------------------------
--Looking at Total Population vs Vaccinations 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations  as int)) over(partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where  dea.continent is not null
order by 2,3

--------------------------------------------------------
--use cte

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations  as int)) over(partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where  dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


-------------------------------------------------------
--Temp Table
drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination  numeric,
rollingpeoplevaccinated numeric
)


insert into #PercentPeopleVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations  as int)) over(partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
--where  dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPeopleVaccinated 

----------------------------------------------------------------------
--craeting view to store data for later visualizations

create view PercentPeopleVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations  as int)) over(partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date
where  dea.continent is not null
--order by 2,3

select * from PercentPeopleVaccinated