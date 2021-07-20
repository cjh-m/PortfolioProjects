SELECT *
FROM PortfolioProject3..NashvilleHousing

-- Remove Time from SaleDate

-- Add new column with date format

ALTER TABLE NashvilleHousing
ADD SaleDateSimplified DATE;

UPDATE NashvilleHousing
SET SaleDateSimplified = CONVERT(Date, SaleDate)

SELECT SaleDateSimplified
FROM PortfolioProject3..NashvilleHousing

----------------------------------------------------------------------
-- Populate Property Address Data

SELECT *
FROM PortfolioProject3..NashvilleHousing
WHERE PropertyAddress IS NULL

-- Self Join to find property address where parcelID is null in one entry but has an address in another entry.
SELECT *
FROM PortfolioProject3..NashvilleHousing a
JOIN PortfolioProject3..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Create new column using ISNULL to eventually replace PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject3..NashvilleHousing a
JOIN PortfolioProject3..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Replacing null values in PropertyAddress column

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject3..NashvilleHousing a
JOIN PortfolioProject3..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------
-- Separate Address into Address, City, State columns

-- Splitting Property Address into two new columns for Street and City
SELECT PropertyAddress
FROM PortfolioProject3..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject3..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject3..NashvilleHousing

-- Owner Address has Street, City AND State

SELECT OwnerAddress
FROM PortfolioProject3..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject3..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject3..NashvilleHousing

------------------------------------------------------------
-- Standardise Sold As Vacant Column to Yes/No

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject3..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject3..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

------------------------------------------------------------------
-- Remove duplicate rows

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM PortfolioProject3..NashvilleHousing
)
/*
Delete duplicate rows

DELETE
FROM RowNumCTE
WHERE row_num > 1
*/

SELECT *
FROM RowNumCTE
WHERE row_num > 1


----------------------------------------------------------------
-- Delete unused columns
-- e.g. original address columns etc.

ALTER TABLE PortfolioProject3..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDateConverted, SaleDate

SELECT *
FROM PortfolioProject3..NashvilleHousing
