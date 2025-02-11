SELECT continent, location FROM PortfolioProject..CovidDeaths
where continent is null or continent = ''
group by continent,location

SELECT top 1000* FROM PortfolioProject..CovidVax
where location = 'Canada'
SELECT top 1000* FROM PortfolioProject..CovidDeaths
where location = 'World'
Order by date desc

--Calculate percentage of deaths if Covid is contracted
SELECT Location
	,date
	,total_deaths
	,total_cases 
	,(CAST(total_deaths as float)/Nullif(CAST(total_cases as float),0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths

--Calculate percentage of population that contracted Covid
SELECT Location
	,date
	,total_cases 
	,population
	,(total_cases/Nullif(population,0))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths

--Calculating Overall Deaths Per Country 
SELECT Continent ,Location
	,MAX(total_deaths) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null and continent != ''
Group by location
Order by 2 desc

--Calculating Overall Deaths Per Continent/Region/Category
SELECT Location
	,MAX(total_deaths) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is null or continent = ''
Group by location
Order by 2 desc

--Calculating Overall Deaths Per Continent
--Eliminating the groupings that do not fall under actual continet
--Using derived table
SELECT Continent, SUM(TotalDeaths) as TotalDeaths FROM
	(SELECT Continent ,Location
		,MAX(total_deaths) as TotalDeaths
	from PortfolioProject..CovidDeaths
	where continent is not null and continent != ''
	Group by Continent,location) A
GROUP BY continent
Order by 2 desc

--Bringing in Vaccination Data

SELECT d.continent, d.location, d.date, population, new_vaccinations
	,SUM(CAST(new_vaccinations as float)) OVER (Partition by d.location Order by d.location, d.date) as RollingTotalVaccinated
SELECT * 
From PortfolioProject..CovidDeaths d
Left Join PortfolioProject..CovidVax v
	ON d.location = v.location
	and d.date = v.date
where d.continent is not null or d.continent != ''

--Percentage of Population Vaccinated
--Using CTE
With PopVacc as(
	SELECT d.continent, d.location, d.date, population, new_vaccinations
		,SUM(CAST(new_vaccinations as float)) OVER (Partition by d.location Order by d.location, d.date) as RollingTotalVaccinated
	From PortfolioProject..CovidDeaths d
	Left Join PortfolioProject..CovidVax v
		ON d.location = v.location
		and d.date = v.date
	where d.continent is not null and d.continent != '')

SELECT continent, location, date, population, new_vaccinations, RollingTotalVaccinated
	,(RollingTotalVaccinated/population)*100 as PercVaccinated
From PopVacc

--Using Temp Table

DROP TABLE if exists #PercPopilationVaccinated

CREATE TABLE #PercPopilationVaccinated (
		Continent varchar(50),
		location varchar(50),
		Date date,
		population float,
		new_vaccinations float,
		RollingTotalVaccinated float)


Insert Into #PercPopilationVaccinated
	SELECT d.continent, d.location, d.date, population,new_vaccinations
		,SUM(CAST(new_vaccinations as float)) OVER (Partition by d.location Order by d.location, d.date) as RollingTotalVaccinated
	From PortfolioProject..CovidDeaths d
	Left Join PortfolioProject..CovidVax v
		ON d.location = v.location
		and d.date = v.date
	where d.continent is not null and d.continent != ''

	Select *,(RollingTotalVaccinated/population)*100 as PercVaccinated
	From #PercPopilationVaccinated

--Using Views

DROP VIEW PercPopulationVaccinated
CREATE VIEW PercPopulationVaccinated as 
	SELECT d.continent, d.location, d.date, population
		,d.new_deaths
		,d.new_cases
		,(CAST(total_deaths as float)/Nullif(CAST(total_cases as float),0))*100 as DeathPercentage
		,people_vaccinated
		,new_vaccinations
		,SUM(CAST(new_vaccinations as float)) OVER (Partition by d.location Order by d.location, d.date) as RollingTotalVaccinated
		,(CAST(people_vaccinated as float)/population)*100 as PercVaccinated
	From PortfolioProject..CovidDeaths d
	Left Join PortfolioProject..CovidVax v
		ON d.location = v.location
		and d.date = v.date
	where d.continent is not null and d.continent != ''
	--and d.location = 'Canada'

Select * From PortfolioProject..PercPopulationVaccinated


	SELECT location, date, total_vaccinations
			,people_vaccinated
			,new_vaccinations
			,SUM(CAST(new_vaccinations as float)) OVER (Partition by location Order by location, date) as RollingTotalVaccinated
	FROM PortfolioProject..CovidVax
	where location = 'Canada'
	Group by location, date, total_vaccinations
			,people_vaccinated
			,new_vaccinations
	
