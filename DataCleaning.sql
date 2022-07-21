SELECT * FROM NashvilleHousing;

----------------------------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format

SELECT SaleDateConverted
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS DATE)

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS DATE)


-----------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B. [UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B. [UniqueID ]
WHERE A.PropertyAddress IS NULL


-------------------------------------------------------------------------------------------------------------------------

-- Breaking Out Address into Individual Columns (Address, City, State)


SELECT *
FROM NashvilleHousing;


SELECT SUBSTRING([PropertyAddress], 1, CHARINDEX(',', PropertyAddress)-1) AS [Address],
SUBSTRING([PropertyAddress], CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS [City]
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING([PropertyAddress], 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING([PropertyAddress], CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM NashvilleHousing;


SELECT 
PARSENAME(REPLACE([OwnerAddress],',','.'), 3) AS [Address],
PARSENAME(REPLACE([OwnerAddress],',','.'), 2) AS [City],
PARSENAME(REPLACE([OwnerAddress],',','.'), 1) AS [State]
FROM NashvilleHousing

ALTER TABLE [dbo].[NashvilleHousing]
ADD [OwnerSplitAddress] NVARCHAR(255);

ALTER TABLE [dbo].[NashvilleHousing]
ADD [OwnerSplitCity] NVARCHAR(255);

ALTER TABLE [dbo].[NashvilleHousing]
ADD [OwnerSplitState] NVARCHAR(255);

UPDATE NashvilleHousing
SET [OwnerSplitAddress] = PARSENAME(REPLACE([OwnerAddress],',','.'), 3);


UPDATE NashvilleHousing
SET [OwnerSplitCity] = PARSENAME(REPLACE([OwnerAddress],',','.'), 2);


UPDATE NashvilleHousing
SET [OwnerSplitState] = PARSENAME(REPLACE([OwnerAddress],',','.'), 1);


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in 'Sold as Vacant' field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;



SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET [SoldAsVacant] = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumber
AS
(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
						ORDER BY UniqueID) AS RowNumber
FROM NashvilleHousing
)
SELECT * FROM RowNumber
WHERE RowNumber > 1


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN [PropertyAddress], [OwnerAddress], [TaxDistrict];

ALTER TABLE NashvilleHousing
DROP COLUMN [SaleDate];







