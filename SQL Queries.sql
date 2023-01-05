use [Portfolio Project];

select * 
from CovidDeaths
where continent != ''
order by 3,4;

-- select * 
-- from CovidVaccinations
-- order by 3,4;

--select location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths
--order by 1,2;

-- Getting countries with their Death Rates
select location, date, total_cases, total_deaths, (total_deaths/nullif(total_cases, 0))*100 as DeathPercentage
from CovidDeaths
where continent != ''
-- where location like '%India%'
order by 1,2;

-- Getting countries with their infection rates
select location, date, total_cases, population, (total_cases/nullif(population,0))*100 as InfectionRate
from CovidDeaths
where continent != ''
-- where location like '%Asia%'
order by 1,2;

-- Getting countries with the highest infection rate
select location, population, max(total_cases) as HighestInfectionRate,
max((total_cases/nullif(population,0))*100) as PercentPopulationInfected
from
CovidDeaths
where continent != ''
group by location, population
order by PercentPopulationInfected desc;

-- Getting countries with the highest death count
select location, max(total_deaths) as HighestDeathCount
from CovidDeaths
where continent != ''
group by location
order by HighestDeathCount desc;


-- Getting Continents with the highest death count
select location, max(total_deaths) as HighestDeathCount
from CovidDeaths
where continent = ''
group by location
order by HighestDeathCount desc;


-- Global Numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/nullif(sum(new_cases),0))*100 as DeathPercentage
from CovidDeaths
where continent != ''
-- group by date
order by 1,2;

-- Total Population vs Vaccinations

with PopVsVac ( Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) PeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent != ''
)


select *, (PeopleVaccinated/Population)*100 as PercentageVaccinated from PopVsVac
order by 2,3;



-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) PeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
-- where cd.continent != ''

select *, (PeopleVaccinated/nullif(Population,0))*100 as PercentageVaccinated 
from #PercentPopulationVaccinated
order by 2,3;


-- creating VIew to store data for later visualizations

create view PercentPopulationVaccinated as (
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) PeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent != ''
);

select * from PercentPopulationVaccinated;