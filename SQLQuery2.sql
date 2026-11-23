-- CLEANING DATA
SELECT * 
FROM PortfolioProject..NashvilleHousing



--STANDARDIZE DATE FORMAT
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate= CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

SELECT SaleDate
FROM PortfolioProject..NashvilleHousing



-- POPULATE PROPERTY ADDRESS DATA
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-- BREAKING OUT ADDRESSES INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1) AS City
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(225);
UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(225);
UPDATE NashvilleHousing
SET PropertyCity= SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1) 


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
From PortfolioProject..NashvilleHousing
Where OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(225);
UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(225);
UPDATE NashvilleHousing
SET OwnerCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(225);
UPDATE NashvilleHousing
SET OwnerState=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerCity, OwnerState
FROM PortfolioProject..NashvilleHousing
--WHERE OwnerAddress IS NOT NULL

-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD
SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing



--REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) AS row_num

FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num >1



--DELETE UNUSED COLUMNS
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

SELECT*
FROM PortfolioProject..NashvilleHousing