-- 1.

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/nullif(sum(new_cases),0))*100 as DeathPercentage
from CovidDeaths
where continent != ''
-- group by date
order by 1,2;

-- 2.
select location, sum(new_deaths) as TotalDeathCount
from CovidDeaths
where continent = ''
and location not like '%income%' 
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc;

-- 3.
select location, population, max(total_cases) as HighestInfectionRate,
max((total_cases/nullif(population,0))*100) as PercentPopulationInfected
from
CovidDeaths
group by location, population
order by PercentPopulationInfected desc;

-- 4.

select location, population, date, max(total_cases) as HighestInfectionRate,
max((total_cases/nullif(population,0))*100) as PercentPopulationInfected
from
CovidDeaths
group by location, population, date
order by PercentPopulationInfected desc;