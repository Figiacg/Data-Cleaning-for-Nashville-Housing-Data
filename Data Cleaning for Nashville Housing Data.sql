/*

Cleaning Data in SQL Queries

*/


select *
from Projects.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format


select SaleDate, convert(date,SaleDate)
from Projects.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

select *
from Projects.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address Data


select *
from Projects.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Projects.dbo.NashvilleHousing a
join Projects.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Projects.dbo.NashvilleHousing a
join Projects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

select *
from Projects.dbo.NashvilleHousing
--where PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address and City)


select PropertyAddress
from Projects.dbo.NashvilleHousing
--where PropertyAddress is null

select substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1),
	   substring(PropertyAddress, charindex(',', PropertyAddress) + 1 , len(PropertyAddress))
from Projects.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1 , len(PropertyAddress))

select *
from Projects.dbo.NashvilleHousing


-- Breaking out OwnerAddress into Individual Columns (Address, City, and State)


select OwnerAddress
from Projects.dbo.NashvilleHousing
--where OwnerAddress is null

select parsename(replace(OwnerAddress, ',', '.') , 3),
	   parsename(replace(OwnerAddress, ',', '.') , 2),
	   parsename(replace(OwnerAddress, ',', '.') , 1)
from Projects.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') , 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') , 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') , 1)

select *
from Projects.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), count(SoldAsVacant)
from Projects.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Projects.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

select *
from Projects.dbo.NashvilleHousing

select distinct(SoldAsVacant), count(SoldAsVacant)
from Projects.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


---------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates


with RowNumCTE as (select *, row_number() over (partition by ParcelID,
												PropertyAddress,
												SalePrice,
												SaleDate,
												LegalReference
												order by UniqueID) as row_num
from Projects.dbo.NashvilleHousing)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

with RowNumCTE as (select *, row_number() over (partition by ParcelID,
												PropertyAddress,
												SalePrice,
												SaleDate,
												LegalReference
												order by UniqueID) as row_num
from Projects.dbo.NashvilleHousing)
delete
from RowNumCTE
where row_num > 1

select *
from Projects.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


select *
from Projects.dbo.NashvilleHousing

alter table Projects.dbo.NashvilleHousing
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

select *
from Projects.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------