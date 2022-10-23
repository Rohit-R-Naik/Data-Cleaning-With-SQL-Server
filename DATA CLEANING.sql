--Data Cleaning a Housing dataset

-- convert saledate datatype from date/time to date
select *
from [clean].dbo.house

select Date_,CONVERT(date,SaleDate)
from [clean].dbo.house;


alter table house
add Date_ date;

UPDATE [clean].dbo.house
set Date_ = CONVERT(date,SaleDate);



------------------------------------------------------------------------------------------------------------------------------------------
--Populating all null values in Property Address Column

SELECT [UniqueID ],ParcelID,PropertyAddress,property_Address
from [clean].dbo.house
where property_Address is null
order by ParcelID



SELECT a.[UniqueID ],a.ParcelID,a.PropertyAddress,a.property_Address
from [clean].dbo.house a
join [clean].dbo.house b
  on a.parcelID=b.parcelID
  and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null
order by a.ParcelID

alter table house
add property_Address varchar(255);

update a
set property_Address = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [clean].dbo.house a
join [clean].dbo.house b
  on a.parcelID=b.parcelID
  and a.UniqueID<>b.UniqueID
--where a.PropertyAddress is null


update [clean].dbo.house
set property_Address = ISNULL(property_Address,PropertyAddress)
from [clean].dbo.house 
------------------------------------------------------------------------------------------------------------------------------------------
--Spliting Property Address to Street Address and City
SELECT property_Address,
	   SUBSTRING(property_Address,1,CHARINDEX(',',property_Address)-1) AS St_Address,
	   SUBSTRING(property_Address,CHARINDEX(',',property_Address)+1,Len(property_Address)) AS City
from [clean].dbo.house

ALTER TABLE [clean].dbo.house
ADD St_Address VARCHAR(255);

UPDATE [clean].dbo.house
SET St_Address =  SUBSTRING(property_Address,1,CHARINDEX(',',property_Address)-1)
FROM [clean].dbo.house



ALTER TABLE [clean].dbo.house
ADD City VARCHAR(255);

UPDATE [clean].dbo.house
SET City = SUBSTRING(property_Address,CHARINDEX(',',property_Address)+1,Len(property_Address))
FROM [clean].dbo.house

SELECT *
FROM [clean].dbo.house

------------------------------------------------------------------------------------------------------------------------------------------
--Splitting Owner address to Street Address, City and State

SELECT [UniqueID ],ParcelID,PropertyAddress,property_Address,OwnerAddress
FROM [clean].dbo.house
where property_Address=OwnerAddress



SELECT [UniqueID ],ParcelID,PropertyAddress,property_Address,OwnerAddress,
       PARSENAME(REPLACE(OwnerAddress,',','.'),3)
	   ,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
	   ,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [clean].dbo.house



ALTER TABLE [clean].dbo.house
ADD Owner_St_Address varchar(255), Owner_City varchar(255), Owner_State varchar(255)


UPDATE [clean].dbo.house
SET Owner_St_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [clean].dbo.house

------------------------------------------------------------------------------------------------------------------------------------------
-- Converting multiple values with same meaning like 'Y = Yes' and 'N= No'


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [clean].dbo.house
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
       CASE
	   WHEN SoldAsVacant= 'Y' THEN 'Yes'
	   WHEN SoldAsVacant= 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [clean].dbo.house

UPDATE [clean].dbo.house
SET SoldAsVacant = CASE
	   WHEN SoldAsVacant= 'Y' THEN 'Yes'
	   WHEN SoldAsVacant= 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [clean].dbo.house

------------------------------------------------------------------------------------------------------------------------------------------

--Deleting Rows with duplicate values


WITH Row_numbers as
(

SELECT *,ROW_NUMBER() OVER (PARTITION BY ParcelID,
									   PropertyAddress,
									   SaleDate,
									   SalePrice,
									   LegalReference ORDER BY UniqueID) as row_num
FROM clean.dbo.house
)
DELETE
from Row_numbers
where row_num>1
------------------------------------------------------------------------------------------------------------------------------------------
--Dropping unwanted columns


select *
from [clean].dbo.house
where SoldAsVacant = 'Yes'


ALTER TABLE clean.dbo.house
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict




