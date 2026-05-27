--cleaning data
select*
from PortfolioProject.dbo.[Housing Data for Data Cleaning]

--standardize data format
Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.[Housing Data for Data Cleaning]

Update [Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date,SaleDate)

Select SaleDate
From PortfolioProject.dbo.[Housing Data for Data Cleaning]



-- Populate Property Address data
Select *
From PortfolioProject.dbo.[Housing Data for Data Cleaning]
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Housing Data for Data Cleaning] a
JOIN PortfolioProject.dbo.[Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Housing Data for Data Cleaning] a
JOIN PortfolioProject.dbo.[Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.[Housing Data for Data Cleaning]
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.[Housing Data for Data Cleaning]

ALTER TABLE [Housing Data for Data Cleaning]
Add PropertySplitAddress Nvarchar(255);
Update [Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [Housing Data for Data Cleaning]
Add PropertySplitCity Nvarchar(255);
Update [Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.[Housing Data for Data Cleaning]


Select OwnerAddress
From PortfolioProject.dbo.[Housing Data for Data Cleaning]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.[Housing Data for Data Cleaning]

ALTER TABLE [Housing Data for Data Cleaning]
Add OwnerSplitAddress Nvarchar(255);
Update [Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Housing Data for Data Cleaning]
Add OwnerSplitCity Nvarchar(255);
Update [Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Housing Data for Data Cleaning]
Add OwnerSplitState Nvarchar(255);
Update [Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.[Housing Data for Data Cleaning]



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.[Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When CAST(SoldAsVacant AS VARCHAR(3)) = '1' THEN 'Yes'
	   When CAST(SoldAsVacant AS VARCHAR(3)) = '0' THEN 'No'
	   ELSE CAST(SoldAsVacant AS VARCHAR(3))
	   END
From PortfolioProject.dbo.[Housing Data for Data Cleaning]

ALTER TABLE PortfolioProject.dbo.[Housing Data for Data Cleaning]
ALTER COLUMN SoldAsVacant VARCHAR(10);

Update [Housing Data for Data Cleaning]
SET SoldAsVacant = CASE When SoldAsVacant  = '1' THEN 'Yes'
	   When SoldAsVacant  = '0' THEN 'No'
	   ELSE SoldAsVacant 
	   END
From PortfolioProject.dbo.[Housing Data for Data Cleaning]



-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.[Housing Data for Data Cleaning]
--order by ParcelID
)
select* --delete
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject.dbo.[Housing Data for Data Cleaning]



-- Delete Unused Columns
Select *
From PortfolioProject.dbo.[Housing Data for Data Cleaning]

ALTER TABLE PortfolioProject.dbo.[Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

