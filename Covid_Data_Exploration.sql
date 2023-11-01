Select *
from COVID_Project_Portfolio_Analysis..CovidDeaths
order by 3,4

--Select *
--from COVID_Project_Portfolio_Analysis..CovidVaccinations
--order by 3,4

-- Select the data that we are using..

Select Location, date, total_cases, new_cases, total_deaths, population
From COVID_Project_Portfolio_Analysis..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- lilelihood of dying
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'death_percentage'
From COVID_Project_Portfolio_Analysis..CovidDeaths
where location like '%Ind%'
order by 1,2

-- Looking at total cases vs the population
-- likelihood of getting infected
Select Location, date, population, total_cases, (total_cases/population)*100 as 'Infected_percentage'
From COVID_Project_Portfolio_Analysis..CovidDeaths
where location like '%Ind%'
order by 1,2

-- Looking at highest infected rate compared to population

Select Location, population, max(total_cases) as 'MAX_Total_CASES', max((total_cases/population))*100 as 'Max_Infected_percentage'
From COVID_Project_Portfolio_Analysis..CovidDeaths
--where location like '%Indi%'
group by Location, population
order by Max_Infected_percentage DESC, Location

--Showing Countries with Highest Death Count per population

Select Location,max(cast(total_deaths as int)) as 'MAX_Total_Death'
From COVID_Project_Portfolio_Analysis..CovidDeaths
--where location like '%Indi%'
where continent is not null
group by Location
order by MAX_Total_Death DESC, Location

--Showing Continents with Highest Death Count per population

Select location,max(cast(total_deaths as int)) as 'MAX_Total_Death'
From COVID_Project_Portfolio_Analysis..CovidDeaths
--where location like '%Indi%'
where continent is null
group by location
order by MAX_Total_Death DESC

--GLOBAL NUMBERS (PerDay)

Select date, SUM(new_cases) as 'Total_New_Cases_Perday', SUM(cast(new_deaths as INT)) as 'Total_New_Deaths_Perday', (SUM(cast(new_deaths as INT))/SUM(new_cases))*100 as 'Total_Death_Percentage_Perday'
-- total_deaths, (total_deaths/total_cases)*100 as 'death_percentage'
From COVID_Project_Portfolio_Analysis..CovidDeaths
--where location like '%Ind%'
where continent is not null
group by date
order by 1,2

--GLOBAL NUMBERS (Total_Cases)
Select SUM(new_cases) as 'Total_New_Cases_Perday', SUM(cast(new_deaths as INT)) as 'Total_New_Deaths_Perday', (SUM(cast(new_deaths as INT))/SUM(new_cases))*100 as 'Total_Death_Percentage_Perday'
-- total_deaths, (total_deaths/total_cases)*100 as 'death_percentage'
From COVID_Project_Portfolio_Analysis..CovidDeaths
--where location like '%Ind%'
where continent is not null
--group by date
order by 1,2


--Joining the 2 tables..

Select *
From COVID_Project_Portfolio_Analysis..CovidDeaths dea
JOIN COVID_Project_Portfolio_Analysis..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.Location Order By dea.location, dea.date)
as RollingPopulationVaccinatedCount,
--(RollingPopulationVaccinatedCount/dea.population)*100
From COVID_Project_Portfolio_Analysis..CovidDeaths dea
JOIN COVID_Project_Portfolio_Analysis..CovidVaccinations vac
     ON dea.location=vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Getting around (CTE)

with PopvsVac (continent,Location,Date,population,new_vaccinations,RollingPopulationVaccinatedCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.Location Order By dea.location, dea.date)
as RollingPopulationVaccinatedCount
--(RollingPopulationVaccinatedCount/dea.population)*100
From COVID_Project_Portfolio_Analysis..CovidDeaths dea
JOIN COVID_Project_Portfolio_Analysis..CovidVaccinations vac
     ON dea.location=vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPopulationVaccinatedCount/population)*100 as Percentage_Population_Vaccinated_Perday from popvsVac

--TEMP Table

Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPopulationVaccinatedCount numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.Location Order By dea.location, dea.date)
as RollingPopulationVaccinatedCount
--(RollingPopulationVaccinatedCount/dea.population)*100
From COVID_Project_Portfolio_Analysis..CovidDeaths dea
JOIN COVID_Project_Portfolio_Analysis..CovidVaccinations vac
     ON dea.location=vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPopulationVaccinatedCount/population)*100 as Percentage_Population_Vaccinated_Perday from #PercentagePopulationVaccinated

--Creating View to Store Data For Later Visualizations 

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.Location Order By dea.location, dea.date)
as RollingPopulationVaccinatedCount
--(RollingPopulationVaccinatedCount/dea.population)*100
From COVID_Project_Portfolio_Analysis..CovidDeaths dea
JOIN COVID_Project_Portfolio_Analysis..CovidVaccinations vac
     ON dea.location=vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from 
PercentagePopulationVaccinated