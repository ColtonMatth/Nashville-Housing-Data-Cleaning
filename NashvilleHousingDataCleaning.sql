/*

Cleaning Data in SQL Queries

*/

Select *
From ProjectPortfolio..NashvilleHousing

------------------------------------------------------------------------------

-- Standarize Date Format

Select saleDateConverted, CONVERT(Date, SaleDate)
From ProjectPortfolio.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date, SaleDate)

Alter Table NashvilleHousing
Add saleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)


------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From ProjectPortfolio.dbo.NashvilleHousing
-- Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProjectPortfolio.dbo.NashvilleHousing a
Join ProjectPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProjectPortfolio.dbo.NashvilleHousing a
Join ProjectPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From ProjectPortfolio.dbo.NashvilleHousing
-- Where PropertyAddress is null
-- Order by ParcelID

-- Breaking out Property Address
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From ProjectPortfolio.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select * 
From ProjectPortfolio.dbo.NashvilleHousing

-- Breaking out Owner Address
Select OwnerAddress
From ProjectPortfolio.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From ProjectPortfolio.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select * 
From ProjectPortfolio.dbo.NashvilleHousing


------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectPortfolio.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldasVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From ProjectPortfolio.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldasVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End


------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	Partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From ProjectPortfolio.dbo.NashvilleHousing
-- Order by ParcelID
)

Select * 
From RowNumCTE
Where row_num > 1
-- Order by PropertyAddress


------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From ProjectPortfolio.dbo.NashvilleHousing

Alter Table ProjectPortfolio.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table ProjectPortfolio.dbo.NashvilleHousing
Drop Column SaleDate