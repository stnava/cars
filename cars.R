library( ANTsR)

# Read in the images

dataDirectory <- './'

fixedImage <- antsImageRead( paste0( dataDirectory, 'ford.jpg' ), dimension = 2 )
movingImage <- antsImageRead( paste0( dataDirectory, 'beetle.jpg' ), dimension = 2 )

# Plot the fixed  and moving images
plot( fixedImage, movingImage, color.overlay = "jet", alpha = 0.7 )

#######
#
# Perform affine registration
#

outputDirectory <- './OutputANTsR/'
if( ! dir.exists( outputDirectory ) )
  {
  dir.create( outputDirectory )
  }
outputPrefix <- paste0( outputDirectory, 'antsrAffine' )

registrationAffine <- antsRegistration(
  fixed = fixedImage, moving = movingImage,
  typeofTransform = 'Affine',
  gradStep = 2.0,
  affSampling = 20,
  affIterations = c( 1500, 1500, 1500, 300, 100, 0 ),
  verbose = TRUE, printArgs = TRUE, outprefix = outputPrefix )

# Plot the fixed and warped moving image
plot( fixedImage, registrationAffine$warpedmovout, color.overlay = "jet", alpha = 0.4 )

#######
#
# Perform deformable registration
#

outputDirectory <- './OutputANTsR/'
if( ! dir.exists( outputDirectory ) )
  {
  dir.create( outputDirectory )
  }
outputPrefix <- paste0( outputDirectory, 'antsrSyN' )

registrationSyN <- antsRegistration(
  fixed = fixedImage, moving = movingImage,
  initialTransform = list( registrationAffine$fwdtransforms[1] ),
  typeofTransform = 'SyNOnly',
  synMetric = 'mattes',
  synSampling = 32,
  gradStep = 0.25,
  affIterations = c( 1500, 1500, 1500, 300, 100, 0 ),
  verbose = TRUE, printArgs = TRUE, outprefix = outputPrefix )

# Plot the fixed and warped moving image
plot( fixedImage, registrationSyN$warpedmovout, color.overlay = "jet", alpha = 0.4 )

similarity <- imageSimilarity( fixedImage,
  movingImage, "ANTSNeighborhoodCorrelation", radius = 4 )
similarityAffine <- imageSimilarity( fixedImage,
  registrationAffine$warpedmovout, "ANTSNeighborhoodCorrelation", radius = 4 )
similaritySyN <- imageSimilarity( fixedImage,
  registrationSyN$warpedmovout, "ANTSNeighborhoodCorrelation", radius = 4 )

antsImageWrite( registrationSyN$warpedmovout, paste0( outputPrefix, "Warped.nii.gz" ) )
antsImageWrite( registrationSyN$warpedfixout, paste0( outputPrefix, "InverseWarped.nii.gz" ) )
