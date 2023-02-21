select * from covid..CovidDeaths order by 3, 4

select * from covid..CovidVaccinations order by 3, 4

--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covid..CovidDeaths order by 1, 2

-- Looking at total cases vs total deaths

---Change column type total_deaths from varchar to float
ALTER TABLE covid..CovidDeaths alter column location nvarchar(255) NOT NULL

ALTER TABLE covid..CovidDeaths
ADD CONSTRAINT CovidDeaths_pk PRIMARY KEY (location, date);

ALTER TABLE covid..CovidDeaths
Alter COLUMN total_deaths float; 
-------------------------------------------------------
select location, Max(total_cases) as total_cases, Max(total_deaths) as total_deaths,
(Max(total_deaths)/Max(total_cases))*100 as deathsPercentage
from covid..CovidDeaths 
where continent is not null
group by location
order by 1

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathsPercentage
from covid..CovidDeaths 
where location like '%Morocco%'
order by 1, 2

--Looking at total_cases vs Population
-- percentage of population got covid
select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as PercentPopulationInfected
from covid..CovidDeaths 
where location like '%Morocco%'
order by 1, 2

-- Looking at Countries infection rate compared to population

select location, population, Max(total_cases) as total_cases, 
(Max(total_cases)/Population)*100 as PercentPopulationInfected
from covid..CovidDeaths 
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing  Countries with the highest deth count per population

select location, Max(total_deaths) as Deaths
from covid..CovidDeaths
where continent is not null
group by location
order by Deaths desc


-- total deaths by continent

select location, Max(total_deaths) as Deaths
from covid..CovidDeaths
where continent is null
group by location
order by Deaths desc


-- total deaths in the world by date

select date, Sum(total_cases) as cases
from covid..CovidDeaths
where continent is not null
group by date
order by cases


-- World Deaths and cases for each day
select date, Sum(new_cases) as cases, Sum(cast(new_deaths as int)) as deaths,
(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as deathsPercentage
from covid..CovidDeaths
where continent is not null
group by date
order by 1, 2

select location, date, new_cases as cases
from covid..CovidDeaths
where date = '2020-01-23 00:00:00.000' 
and continent is not null
order by cases 

-- Vaccination per Country

with popVac (continent, location, date, Population, new_vaccinations, total_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as total_vaccination
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (total_vaccination/Population)*100 as percentagePeapleVac 
from popVac


-- create view for visualization
create view PopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as total_vaccination
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * from PopulationVaccinated