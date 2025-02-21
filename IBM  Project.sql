CREATE TABLE ibm (
    Age INT,
    Attrition VARCHAR(10),
    BusinessTravel VARCHAR(50),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT PRIMARY KEY,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(100),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(5),
    OverTime VARCHAR(10),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT DEFAULT 40,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

COPY ibm 
FROM 'D:\Data Analyst\Projects Data\IBM.csv'
DELIMITER ',' 
CSV HEADER;


-- Total data

select * from ibm;

1) -- How many male and female workers ?

select gender, count(gender) as num
from ibm
group by gender;


2) -- List of all Department & Employee Count

select department, count(employeecount) as labours
from ibm
group by department;

3) -- Average Salary by department & job role 

select round(avg(monthlyrate),2), jobrole
from ibm
group by jobrole;

4) --Top 5 highest Paid

select jobrole, monthlyrate
from ibm
order by monthlyrate desc
limit 5 offset 5;

5) -- Attrition

Select Attrition,Count(*) From ibm
group by Attrition;

6) -- attrition rate

select count(*) filter (where attrition = 'Yes') * 100.0 / count(*) as attrition_rate  
from ibm;

7) -- attrition rate per department

select department, count(*) filter (where attrition = 'Yes') * 100.0 / count(*) as attrition_rate  
from ibm  
group by department  
order by attrition_rate desc;

8) -- average job satisfication

select department, avg(job_satisfaction) as avg_satisfaction  
from ibm  
group by department;

9) --average monthly income 

select job_role, avg(monthly_income) as avg_income  
from ibm  
group by job_role  
order by avg_income desc;

10) -- over time 
select overtime, count(*) * 100.0 / (select count(*) from ibm) as percentage  
from ibm  
group by overtime;

11) -- gender ratio in each department  
select department, gender, count(*)  
from ibm  
group by department, gender;  

12) -- average salary hike percentage based on job level  
select job_level, avg(percent_salary_hike)  
from ibm  
group by job_level  
order by job_level;  

13) -- correlation between years at company and salary  
select years_at_company, avg(monthly_income)  
from ibm  
group by years_at_company  
order by years_at_company;

14) -- average performance rating by job role  
select job_role, avg(performance_rating)  
from ibm  
group by job_role;  

15) -- how distance from home affects attrition  
select distance_from_home, count(*) filter (where attrition = 'yes') * 100.0 / count(*) as attrition_rate  
from ibm  
group by distance_from_home  
order by distance_from_home;  

16) -- attrition patterns based on years since last promotion  
select years_since_last_promotion, count(*) filter (where attrition = 'yes') * 100.0 / count(*) as attrition_rate  
from ibm  
group by years_since_last_promotion  
order by years_since_last_promotion;  

17) -- factors contributing the most to employee satisfaction  
select job_satisfaction, work_life_balance, relationship_satisfaction, avg(monthly_income)  
from ibm  
group by job_satisfaction, work_life_balance, relationship_satisfaction  
order by job_satisfaction desc;  

18) -- impact of promotions on attrition
select a.overtime, avg(a.monthlyincome) as avgsalary, avg(b.performancerating) as avgperformance  
from ibm a  
join ibm b on a.employeenumber = b.employeenumber  
group by a.overtime  
order by avgperformance desc;  


19) -- Employee Attrition and Salary Insights
select a.employeenumber, a.age, a.jobrole, a.department, a.monthlyincome, b.avgsalary, a.attrition  
from ibm a  
join (  
    select jobrole, avg(monthlyincome) as avgsalary  
    from ibm  
    group by jobrole  
) b on a.jobrole = b.jobrole  
where a.attrition = 'yes'  
order by a.monthlyincome desc;  


20) --Finds the attrition rate per job role and department, along with total employees in each

select a.department, a.jobrole, a.attritionrate, b.totalemployees  
from (  
    select department, jobrole, count(*) filter (where attrition = 'yes') * 100.0 / count(*) as attritionrate  
    from ibm  
    group by department, jobrole  
) a  
join (  
    select department, jobrole, count(*) as totalemployees  
    from ibm  
    group by department, jobrole  
) b on a.department = b.department and a.jobrole = b.jobrole  
order by a.attritionrate desc; 

21) --Work-Life Balance and Job Satisfaction Analysis

select a.jobrole, a.worklifebalance, b.avgsatisfaction  
from ibm a  
join (  
    select jobrole, avg(jobsatisfaction) as avgsatisfaction  
    from ibm  
    group by jobrole  
) b on a.jobrole = b.jobrole  
order by a.worklifebalance desc;  

22) --finding key factors influencing attrition with salary, distance, and job Role

with attrition_analysis as (
    select 
        ibm.employee_number,
        ibm.age,
        ibm.job_role,
        ibm.department,
        ibm.monthly_income,
        ibm.distance_from_home,
        ibm.attrition,
        ibm.years_at_company,
        ibm.years_since_last_promotion,
        ibm.work_life_balance,
        ibm.overtime,
        rank() over (partition by ibm.department order by ibm.monthly_income desc) as salary_rank
    from ibm
),
avg_attrition_factors as (
    select 
        job_role,
        avg(distance_from_home) as avg_distance,
        avg(monthly_income) as avg_salary,
        avg(years_since_last_promotion) as avg_years_since_promotion,
        avg(work_life_balance) as avg_work_life_balance
    from ibm
    group by job_role
)
select 
    a.employee_number,
    a.age,
    a.job_role,
    a.department,
    a.monthly_income,
    a.distance_from_home,
    a.attrition,
    a.years_at_company,
    a.years_since_last_promotion,
    a.work_life_balance,
    a.overtime,
    a.salary_rank,
    b.avg_distance,
    b.avg_salary,
    b.avg_years_since_promotion,
    b.avg_work_life_balance
from attrition_analysis a
join avg_attrition_factors b on a.job_role = b.job_role
where a.attrition = 'yes'
order by a.department, a.salary_rank desc;







