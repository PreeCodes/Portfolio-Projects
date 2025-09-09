/* Cleaning Data in SQL */

select * from PortfolioProject..NashvilleHousing

-----------------------------------------------------------
-- Standardize Date Format

select SaleDateConverted, convert(date, saledate) 
from PortfolioProject..NashvilleHousing

update NashvilleHousing 
set SaleDate = convert(date, SaleDate)

Alter table NashvilleHousing 
add SaleDateConverted Date;

update NashvilleHousing 
set SaleDateConverted = CONVERT(date, SaleDate)

----------------------------------------------------------
-- Populate Property Address Data

select * from NashvilleHousing 
where PropertyAddress is null
--order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
isnull(a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing a 
join NashvilleHousing b 
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing a 
join NashvilleHousing b 
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

----------------------------------------------------------------------
-- Breaking out Address into Individual COlumns (Address, City, State)
-- PropertyAddress

select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address2
from NashvilleHousing

Alter table NashvilleHousing 
add PropertySplitAddress nvarchar(255);

update NashvilleHousing 
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing 
add PropertySplitCity nvarchar(255);

update NashvilleHousing 
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select * from NashvilleHousing

-- OwnerAddress (Easier than Substring)

select OwnerAddress  
from NashvilleHousing

select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1) 
from NashvilleHousing

Alter table NashvilleHousing 
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing 
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing 
add OwnerSplitCity nvarchar(255);

update NashvilleHousing 
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing 
add OwnerSplitState nvarchar(255);

update NashvilleHousing 
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select *  
from NashvilleHousing

-----------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant) 
from NashvilleHousing

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes' 
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant 
	 end
from NashvilleHousing

update NashvilleHousing 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant 
						end

select distinct(SoldAsVacant) 
from NashvilleHousing 

-----------------------------------------------------------------------
-- Remove Duplicates

with RownumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
			PropertyAddress,
			SaleDate, 
			SalePrice,
			LegalReference 
			order by UniqueID)row_num 
from NashvilleHousing
)
select *    
from RownumCTE 
where row_num > 1 
order by PropertyAddress


with RownumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
			PropertyAddress,
			SaleDate, 
			SalePrice,
			LegalReference 
			order by UniqueID)row_num 
from NashvilleHousing
)
delete  
from RownumCTE 
where row_num > 1 
--order by PropertyAddress

--------------------------------------------------------------------

-- Delete Unused Columns

select * from NashvilleHousing

alter table NashvilleHousing 
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate