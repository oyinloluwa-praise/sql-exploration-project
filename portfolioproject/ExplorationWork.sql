select*
from [portfolio Project]..deaths
order by 3,4

-- selecting the data to be used
select country, date, population, total_cases, new_cases, total_deaths
from [portfolio Project]..deaths
order by 1,2

-- Total cases vs total deaths
select country, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio Project]..deaths
Where total_cases > 0
order by 1,2

-- Total deaths vs population
select country, date, population, total_deaths, (total_deaths/population)*100 as DeathcountPercentage
from [portfolio Project]..deaths
-- where country like 'africa' , this will be used if i wanted to get the exact calculation for a place
order by 1,2

-- Total cases vs population
select country, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
from [portfolio Project]..deaths
-- where country like '%africa%' , this will be used if i wanted to get the exact calculation for a place
order by 1,2

-- comparing high infection rate by population
Select country, population, date, MAX(total_cases) as highestcount, MAX((total_cases/population))*100 as highestInfectedPercent
From [portfolio Project]..deaths
--where country like '%states%'
Group by country,population, date
Order by highestInfectedPercent desc

-- showing countries with the highest count per population
Select country, MAX(cast(total_deaths as int)) as TotalDeathCount
From [portfolio Project]..deaths
--where country like '%states%'
Group by country
Order by TotalDeathCount desc

-- total numbers
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_cases)/SUM(new_deaths))*100 as DeathPercentage
From [portfolio Project]..deaths
order by 1,2

--for the vaccinations
select*
from [portfolio Project]..vaccinations

--joining the two tables together
select*
from [portfolio Project]..deaths
join [portfolio Project]..vaccinations
on deaths.country = vaccinations.country
and deaths.date = vaccinations.date

-- total population vs vaccinations
SELECT deaths.country, deaths.date, deaths.population,
    TRY_CONVERT(DECIMAL(18,2), vaccinations.new_vaccinations) AS new_vaccinations_deci,
    SUM(TRY_CONVERT(DECIMAL(18,2), vaccinations.new_vaccinations)) 
        OVER (PARTITION BY deaths.country ORDER BY deaths.country, deaths.date) AS cumulativeOfPeopleVaccinated
FROM [portfolio Project]..deaths
JOIN [portfolio Project]..vaccinations
    ON deaths.country = vaccinations.country
   AND deaths.date = vaccinations.date
ORDER BY deaths.country, deaths.date, deaths.population;

-- with CTE
with PopvsVac (country, date, population,new_vaccinations, cumulativeOfPeopleVaccinated) as
(
SELECT deaths.country, deaths.date, deaths.population,
    TRY_CONVERT(DECIMAL(18,2), vaccinations.new_vaccinations) AS new_vaccinations_deci,
    SUM(TRY_CONVERT(DECIMAL(18,2), vaccinations.new_vaccinations)) 
        OVER (PARTITION BY deaths.country ORDER BY deaths.country, deaths.date) AS cumulativeOfPeopleVaccinated
FROM [portfolio Project]..deaths
JOIN [portfolio Project]..vaccinations
    ON deaths.country = vaccinations.country
   AND deaths.date = vaccinations.date
--ORDER BY deaths.country, deaths.date, deaths.population
)

select*, (cumulativeOfPeopleVaccinated/population)*100
from PopvsVac


-- with temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(country nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativeOfPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT deaths.country, deaths.date, deaths.population,
    TRY_CONVERT(DECIMAL(18,2), vaccinations.new_vaccinations) AS new_vaccinations_deci,
    SUM(TRY_CONVERT(DECIMAL(18,2), vaccinations.new_vaccinations)) 
        OVER (PARTITION BY deaths.country ORDER BY deaths.country, deaths.date) AS cumulativeOfPeopleVaccinated
FROM [portfolio Project]..deaths
JOIN [portfolio Project]..vaccinations
    ON deaths.country = vaccinations.country
   AND deaths.date = vaccinations.date
--ORDER BY deaths.country, deaths.date, deaths.population

select*, (cumulativeOfPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for visulization later
--create view PercentofpeopleVaccinated as

SELECT deaths.country, deaths.date, deaths.population,
    TRY_CONVERT(DECIMAL(18,2), vaccinations.new_vaccinations) AS new_vaccinations_deci,
    SUM(TRY_CONVERT(DECIMAL(18,2), vaccinations.new_vaccinations)) 
        OVER (PARTITION BY deaths.country ORDER BY deaths.country, deaths.date) AS cumulativeOfPeopleVaccinated
FROM [portfolio Project]..deaths
JOIN [portfolio Project]..vaccinations
    ON deaths.country = vaccinations.country
   AND deaths.date = vaccinations.date
--ORDER BY deaths.country, deaths.date, deaths.population


select*
from PercentofpeopleVaccinated