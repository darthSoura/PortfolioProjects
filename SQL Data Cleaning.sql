-- select * 
-- from NashvilleHousing;

-- Standardise Date Format
select SaleDate, convert(Date, SaleDate)
from NashvilleHousing;

Alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate);


-- Populate Property Address Data

select distinct ParcelID, PropertyAddress
from NashvilleHousing
order by 1;

select a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
where a.PropertyAddress is null;


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;



-- Breaking Address into individual columns (Address, City, State)

select PropertyAddress from NashvilleHousing;

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
distinct substring(PropertyAddress, charindex(',', PropertyAddress)+2, LEN(PropertyAddress)) as Address
from NashvilleHousing;


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1);

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+2, len(PropertyAddress));


select * from NashvilleHousing;

-- Do for OwnerAddress

select OwnerAddress from NashvilleHousing;

select
parsename(replace(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
parsename(replace(OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
parsename(replace(OwnerAddress, ',', '.'), 1) as OwnerSplitState
from NashvilleHousing;

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3);

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2);

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1);

select * from NashvilleHousing;

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end;

-- remove duplicates

with RowNumCTE as (
select *, ROW_NUMBER() over(
		partition by ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate, 
					LegalReference
		order by UniqueID) row_num
from NashvilleHousing
)

select * 
from RowNumCTE
where row_num >1
order by PropertyAddress;

delete 
from RowNumCTE
where row_num>1;

-- delete ununsed columns

select * from NashvilleHousing;

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress;

alter table NashvilleHousing
drop column SaleDate;
