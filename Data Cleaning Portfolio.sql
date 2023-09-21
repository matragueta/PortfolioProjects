/* Cleaning Data in SQL queries */

select * 
from PortfolioProject..NashvilleHousing

-- Standardize Data Format

select SaleDateConverted, CONVERT(date, saledate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, saledate)

Alter Table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, saledate)
------------------------------------------------------------------------------------
-- Populate Property Address data

select * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, a.SaleDate, a.SalePrice, b.ParcelID, b.PropertyAddress, 
b.SaleDate, b.SalePrice
--, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING (PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
add PropertySplitAddress varchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING (PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
add PropertySplitCity varchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select OwnerAddress 
from PortfolioProject..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitAddress varchar(255);

Alter Table NashvilleHousing
add OwnerSplitCity varchar(255);

Alter Table NashvilleHousing
add OwnerSplitState varchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------
-- Breaking out Owner Name into First Name and Last Name

select
SUBSTRING (OwnerName, 1,
case when CHARINDEX(',', OwnerName) = 0 then LEN(OwnerName)
else CHARINDEX (',', OwnerName) -1 end) as LastName
, SUBSTRING (OwnerName, CHARINDEX(',', OwnerName) + 2 , len(OwnerName)) as FirstName
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerFirstName varchar(255);

Alter Table NashvilleHousing
Add OnwnerLastName varchar (255);

Alter Table NashvilleHousing
Add OwnerLastName varchar (255);

select * from PortfolioProject..NashvilleHousing

update NashvilleHousing
set OwnerFirstName = SUBSTRING (OwnerName, CHARINDEX(',', OwnerName) + 2 , len(OwnerName))

update NashvilleHousing
set OwnerLastName = SUBSTRING (OwnerName, 1,
case when CHARINDEX(',', OwnerName) = 0 then LEN(OwnerName)
else CHARINDEX (',', OwnerName) -1 end)

------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct (SoldAsVacant)
from PortfolioProject..NashvilleHousing

select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
						when SoldAsVacant = 'N' THEN 'No'
						else SoldAsVacant
						end


------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					)as row_num

 from PortfolioProject..NashvilleHousing
 --order by ParcelID
 )
select * 
from RowNumCTE
where row_num > 1 
order by ParcelID

------------------------------------------------------------------------------------

-- Delete unused columns

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate, OwnerName





