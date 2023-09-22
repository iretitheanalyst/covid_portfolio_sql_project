SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccine
--ORDER BY 3,4

Select Location, Population, date, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--to detremine the percentage deaths

Select Location, date, Population, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
Order by 1,2


-- total cases against population

Select Location, date, Population, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths, (total_cases/population)*100 as PercentageCases
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Order by 1,2


-- to determine the countries with the highest number of infection rate compared with population

Select Location, Population, MAX(total_deaths) as HighestInfectionCount, Max((total_deaths/population))*100 as PercentageInfectionCases
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Group by Location, Population
Order by PercentageInfectionCases desc


--to determine the countries with the highest number of death rate

Select Location, Population, Max(total_deaths) as HighestDeathRate, MAX((total_deaths/population))*100 as PercentageDeathCases
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentageDeathCases desc


Select Location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location
Order by HighestDeathCount desc

--By continent/location

Select Location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is null
Group by Location
Order by HighestDeathCount desc


Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
Order by HighestDeathCount desc


--GROU BY GLOBAL NUMBERS

Select date, SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as PercentageDeaths
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2 


--Linking vaccination and deaths to get the total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as TotalSumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Location, Continent, Date,Population, new_vaccination, TotalSumPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalSumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

SELECT * ,(TotalSumPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac




--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
TotalSumPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalSumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

SELECT * ,(TotalSumPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Craeting View to be used by visualization later

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalSumPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select * From PercentPopulationVaccinated