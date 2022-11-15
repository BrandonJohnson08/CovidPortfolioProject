Use [Portfolio Project (COVID)]

Select *
From CovidDeaths
Where continent is not null
Order by 3,4


Select location,date,total_cases,new_cases,total_deaths,population
From CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases Vs Total Deaths by Country

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From CovidDeaths
Where location like '%States%' 
Order by 1,2


--Total Cases Vs Population
--Shows Population that Contracted Covid



Select location,date,population,total_cases, (total_cases/population)*100 as ContractedCovidPercent
From CovidDeaths
Where location like '%States%' 
Order by 1,2


--Country w/ Highest Infection Rate Compared to Population

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as ContractedCovidPercent
From CovidDeaths
Where continent is not null
Group By location, population
Order by ContractedCovidPercent desc


--Country w/ Highest Death Rates

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By location
Order by TotalDeathCount desc

--Continent w/ Highest Death Rates

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount desc

--Looking at Total Cases Vs Total Deaths by Continent

Select continent,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From CovidDeaths
Where continent is not null 
Order by 1,2

--Continent w/ Highest Infection Rate Compared to Population per day

Select date,continent,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as ContractedCovidPercent
From CovidDeaths
Where continent is not null
Group By continent, population, date
Order by ContractedCovidPercent desc

--Continent w/ Highest Infection Rate Compared to Population

Select continent,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as ContractedCovidPercent
From CovidDeaths
Where continent is not null
Group By continent, population
Order by ContractedCovidPercent desc



--------------------------------------------------------------------------------------------Global Numbers ----------------------------------------------------------------------------------------------------------------------------------

--Total Cases Vs Death Percentage Globally 

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(New_Deaths as int))/SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
--Group By Date 
Order By 1,2

--Joins Covid Deaths w/ Covid Vax 


Select *
From CovidDeaths dea
Join CovidVax vax
On dea.location = vax.location
and dea.date = vax.date


--Total Population Vs Vaccinations per Day
--SET ANSI_WARNINGS OFF 
--GO
--Used BigInt Due to "Arithmetic overflow error converting expression to data type int." msg

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.date) as RollingVax
From CovidDeaths dea
Join CovidVax vax
On dea.location = vax.location
and dea.date = vax.date
Where dea.continent is not null
Order by 2,3




--Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.date) as RollingVax
From CovidDeaths dea
Join CovidVax vax
On dea.location = vax.location
and dea.date = vax.date
Where dea.continent is not null
Order by 2,3

--Using CTE
-- New Vaccinations Per Country Using a Rolling Counter "RollingVax"

With PopVsVax (Continent,Location,Date,Population, New_Vaccinations, RollingVax)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.date) as RollingVax
From CovidDeaths dea
Join CovidVax vax
On dea.location = vax.location
and dea.date = vax.date
Where dea.continent is not null
)
Select *
From PopVsVax


--Using CTE
-- New Vaccinations Per Country Using a Rolling Counter "RollingVax"
-- Total Population Vax'd Per day By Country


With PopVsVax (Continent,Location,Date,Population, New_Vaccinations, RollingVax)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.date) as RollingVax
From CovidDeaths dea
Join CovidVax vax
On dea.location = vax.location
and dea.date = vax.date
Where dea.continent is not null
)
Select *, (RollingVax/Population)*100
From PopVsVax




--Temp Table
--Drop Table if Exists 

Create Table #PercentPopulationVaxD
(Continent nvarchar(255),Location nvarchar (255), Date datetime, Population numeric, New_Vaccinations numeric, RollingVax numeric)


Insert Into #PercentPopulationVaxD
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.date) as RollingVax
From CovidDeaths dea
Join CovidVax vax
On dea.location = vax.location
and dea.date = vax.date
Where dea.continent is not null
Order by 2,3

Select *, (RollingVax/Population)*100
From #PercentPopulationVaxD


--Creating Views for Vizualization

Create View PercentPopulationVaxD as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.date) as RollingVax
From CovidDeaths dea
Join CovidVax vax
On dea.location = vax.location
and dea.date = vax.date
Where dea.continent is not null
--Order by 2,3


Create View TotalCasesVsDeathPercentage AS
Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(New_Deaths as int))/SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null


Create View United_States_Cases_Vs_Deaths AS
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From CovidDeaths
Where location like '%States%' 




Create View Cases_Vs_Population As
Select location,date,population,total_cases, (total_cases/population)*100 as ContractedCovidPercent
From CovidDeaths
Where location like '%States%' 
--Order by 1,2

Create View DeathbyContinent As
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By continent


Create View HighestInfectionRatePerCountry As
Select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as ContractedCovidPercent
From CovidDeaths
Where continent is not null
Group By location, population
--Order by ContractedCovidPercent desc

Create View HighestInfectionRatePerCountryandDate As
Select location,population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as ContractedCovidPercent
From CovidDeaths
Where continent is not null
Group By location, population, date
--Order by ContractedCovidPercent desc
