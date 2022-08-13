
select location, dates, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 2, 1

-- Looking at Total Cases vs Total Deaths

select location, dates, total_cases, total_deaths, ((total_deaths * 1.0) / total_cases) * 100  as death_percentage
from covid_deaths
where location like '%ndia'
order by 1, 2

--Total cases vs the population
select location, dates, total_cases, population, total_cases  * 100.0 / population as case_percentage, 
total_deaths, total_deaths * 100.0 / population  as death_percentage_pop 
from covid_deaths
where location like '%ndia'
order by 1, 2

--Countries with highest Infection rate compared to population
select location, population, max(total_cases), max(total_cases * 100.0 / population) as percentage_infection
from covid_deaths
where total_cases is not null 
group by location, population
order by percentage_infection desc

--Countries with highest death count
select location, max(total_deaths) as total_death_counts
from covid_deaths
where total_deaths is not null and continent is not null
group by location
order by total_death_counts desc

--Countries with highest death count per population
select location, population, max(total_deaths) as total_death_counts, max(total_deaths) * 100.0 / population as pop_perc
from covid_deaths
where total_deaths is not null and continent is not null
group by location, population
order by pop_perc desc

--Continent wise 
select location, max(total_deaths) as total_death_counts
from covid_deaths
where continent is null
group by location
order by total_death_counts desc

--showing continents with highest death count per population

select location, population, max(total_deaths) as total_death_counts, max(total_deaths) * 100.0 / population as pop_perc
from covid_deaths
where continent is null
group by location, population
order by pop_perc desc

--Global Numbers date wise

select dates, sum(new_cases) as sum_cases, sum(new_deaths) as sum_deaths, sum(new_deaths) * 100.0 / sum(new_cases) as death_percentage
from covid_deaths
where continent is not null
group by dates
order by 1, 2


--looking at total population vs total vaccination

select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dates) as comm_vacc
from covid_deaths as dea
join covid_vaccine as vac
    on dea.location = vac.location
    and dea.dates = vac.dates
where dea.continent is not null
order by 2, 3

-- Use a CTE

with PopvsVac(continent, location, dates, population, new_vaccinations, comm_vac)
as
(
select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dates) as comm_vacc
from covid_deaths as dea
join covid_vaccine as vac
    on dea.location = vac.location
    and dea.dates = vac.dates
where dea.continent is not null
--order by 2, 3
)
select * , comm_vac * 100.0 / population as perc_vacc
from PopvsVac


-- use a TEMP table
drop table if exists percentpopvacc;
Create temp table percentpopvacc (continent varchar, location varchar, 
 dates date, population bigint, new_vaccinations bigint, comm_vac numeric);
Insert into percentpopvacc
select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dates) as comm_vacc
from covid_deaths as dea
join covid_vaccine as vac
    on dea.location = vac.location
    and dea.dates = vac.dates
where dea.continent is not null;
select * , comm_vac * 100.0 / population as perc_vacc
from percentpopvacc;

--creating view to store data for later visualizations

create view perc_pop_vacc as
select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dates) as comm_vacc
from covid_deaths as dea
join covid_vaccine as vac
    on dea.location = vac.location
    and dea.dates = vac.dates
where dea.continent is not null;


