--Pull information from CovidDeath table

Select *
from [Portfolio Project]..CovidDeath$
Order by 3 ,4

Select *
from [Portfolio Project]..CovidDeath$
Where continent is null
Order by 3 ,4 

Select *
from [Portfolio Project]..CovidDeath$
Where continent is not null
order by  3,4

-- comparing the demands in above we can summarize the following
/** 

There is 8,487 null rows with continent, and 124,385 with continent values 
(Total row 132,872)

**/

-- We are going to work on data where the continent is not null

Select location , date , population , total_cases , new_cases , total_deaths , new_deaths
from [Portfolio Project]..CovidDeath$
Where continent is not null
order by  1 ,2

-- Total cases VS total cases

Select location , date , population , total_cases , total_deaths , (total_deaths / total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeath$
Where continent is not null and total_deaths is not null
order by 1 ,2

--Total cases Vs Total death at your country
Select location , date , population , total_cases , total_deaths , (total_deaths / total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeath$
Where continent is not null and total_deaths is not null 
and location like '%Pales%'
order by 2
-- (In my country the Avg_death increase at the first then it become consistant then he start to decrease)

--Total cases VS population
-- (Shows what percentage of population got covid)

Select location , date , population , total_cases , total_deaths , (total_cases / population) as Percent_Population_Infected
from [Portfolio Project]..CovidDeath$
Where continent is not null
order by 1,2 

--Total cases VS population in your country
Select location , date , population , total_cases , total_deaths , (total_cases / population)*100 as Percent_Population_Infected
from [Portfolio Project]..CovidDeath$
Where continent is not null and location like '%Pale%'
order by 2 

-- (So,By the end of 2021, if you are in my country the probability that you will had covid19 is 8.7%)

-- The country with the highest infection rate
Select location , population, total_cases,(total_cases / population)*100 as Percent_Population_Infected
from [Portfolio Project]..CovidDeath$
Where continent is not null and total_cases is not null 
order by 4 desc

-- After running the pervious query, we can see that Montenegro has the highest infection rate)
--The next query will show all the countries from the highest to lowest
Select location ,population , MAX( total_cases / population)*100 as Percent_Population_Infected
from [Portfolio Project]..CovidDeath$
Where continent is not null and total_cases is not null
group by location , population
order by  3 desc

/** 
Showing countries with the highest Death count
United states has the highest death cases
**/
Select location , Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeath$
Where continent is not null
group by location 
order by 2 desc

--In my country

Select location, population,max(cast(total_deaths as int )) As max_death
 from [Portfolio Project]..CovidDeath$
Where continent is not null 
and location like 'Pal%'
group by  population,location 
order by 3 desc

-- BREAKING THINGS DOWN BY CONTINENT

/** 
Form the next two queries ,Showing continent with the highest Death count
We can see that when using loction with continent is null have more accurat reaults
from the code when we use continent not null, thats mean that when the continent
is null they put the real continent in location col. (human error)
**/

Select location , Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeath$
Where continent is null
group by location
order by 2 desc

Select continent , Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeath$
Where continent is not null
group by continent
order by 2 desc


-- GLOBAL NUMBERS

select sum(total_cases) as totalcases , sum(population) as Totalpopulation , (sum(total_cases)/sum(population)) *100 as GlobalInfRate
from [Portfolio Project]..CovidDeath$
Where continent is not null

select sum(new_cases) as newcases , sum(cast(new_deaths as int)) as newdeath , (sum(cast(new_deaths as int))/sum(new_cases)) *100 as deathpercentage
from [Portfolio Project]..CovidDeath$
Where continent is not null

--Pull information from vaccation table to see
 select *
 from [Portfolio Project]..CovidVaccanation$

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.location , dea.population , dea.date , Cast(vac.new_vaccinations as int) as new_vaccinations , ( Cast(vac.new_vaccinations as int)/ dea.population )*100 as Vac_Rate
from [Portfolio Project]..CovidDeath$ dea
join [Portfolio Project]..CovidVaccanation$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where vac.new_vaccinations is not null and dea.population is not null
 order by 5 desc

 --Cumulative amounts of vaccation order by countries
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int , vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinated
/**the sum function in above related to cumulative amounts of people who got vaccain
the partition by clause order by location to see the records for each country togother **/
From [Portfolio Project]..CovidDeath$ dea
Join [Portfolio Project]..CovidVaccanation$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVacc (continent , date , loction , population , new_vaccinations , RollingPeopleVaccinated )
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int , vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeath$ dea
Join [Portfolio Project]..CovidVaccanation$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select * , (RollingPeopleVaccinated/population) as rollingpersentage
from PopvsVacc
where RollingPeopleVaccinated is not null 

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric )

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project] ..CovidDeath$ dea
Join [Portfolio Project]..CovidVaccanation$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

