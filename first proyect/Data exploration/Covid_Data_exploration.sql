--select *
--from Portafolio..covid_test$
--order by 3,4

select *
from Portafolio..covid_vaccination$
where continent is not null
order by 3,4

-- select data that is going to be used
--select location,date,total_cases,new_cases,total_deaths,population
--from Portafolio..covid_test$
--order by 1,2

-- looking at total cases vs  total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as porcentage_deads
from Portafolio..covid_test$
where location = 'Colombia'
order by 1,2

-- looking total case vs popu;ation 
-- porcentage of population got covid
select location,date,total_cases,(total_cases/population)*100 as population_covid
from Portafolio..covid_test$
where location = 'Colombia'
order by 1,2

-- Highest infection rate per population 
select location, MAX(total_cases) AS HighestInfection ,MAX((total_cases/population))*100 as Percentage_Population_Infected
from Portafolio..covid_test$
where continent is not null
--where location = 'Colombia'
Group by location, population
order by Percentage_Population_Infected DESC


-- Showing the contries with highest death count per population 

select location, MAX(cast(total_deaths as int)) as total_death_count
from Portafolio..covid_test$
--where location = 'Colombia'
where continent is not null
Group by location
order by total_death_count DESC


select location, MAX(cast(total_deaths as int)) as total_death_count
from Portafolio..covid_test$
--where location = 'Colombia'
where continent is  null
Group by location
order by total_death_count DESC


-- showing the continent with the highest deaths 

select continent, MAX(cast(total_deaths as int)) as total_death_count
from Portafolio..covid_test$
--where location = 'Colombia'
where continent is not null
Group by continent
order by total_death_count DESC


-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as porcentage_deads
from Portafolio..covid_test$
where continent is not null 
order by 1,2



--------------------- VACCINATION 
select *
from Portafolio..covid_vaccination$

-- Looking total population vs vaccination

select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
from Portafolio..covid_test$ dea
join Portafolio..covid_vaccination$ vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3



select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Portafolio..covid_test$ dea
join Portafolio..covid_vaccination$ vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

 --USE CTE

 with PopVsVac (Continent, Location , Date, Population,New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Portafolio..covid_test$ dea
join Portafolio..covid_vaccination$ vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac


-- Temp table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime, 
	Population numeric, 
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric)



Insert into #PercentPopulationVaccinated
 select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Portafolio..covid_test$ dea
join Portafolio..covid_vaccination$ vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later vizualizations


Create View PercentPopulationVaccinated as 
	 select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
	from Portafolio..covid_test$ dea
	join Portafolio..covid_vaccination$ vac on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null


Select *
from PercentPopulationVaccinated





 
