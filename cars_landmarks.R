library( ANTsR)
layout( matrix(1:2,nrow=1))

# Read in the images

dataDirectory <- './'

fixedImage <- antsImageRead( paste0( dataDirectory, 'ford.jpg' ), dimension = 2 )
movingImage <- antsImageRead( paste0( dataDirectory, 'beetle.jpg' ), dimension = 2 )

fixedImageLM <- antsImageRead( paste0( dataDirectory, 'ford_landmarks.nii.gz' ), dimension = 2 )
movingImageLM <- antsImageRead( paste0( dataDirectory, 'beetle_landmarks.nii.gz' ), dimension = 2 )
fixedImageLM1 = thresholdImage( fixedImageLM, 1, 1 )
movingImageLM1 = thresholdImage( movingImageLM, 1, 1 )
fixedImageLM2 = thresholdImage( fixedImageLM, 2, 2 )
movingImageLM2 = thresholdImage( movingImageLM, 2, 2 )
# Plot the fixed  and moving images
plot( fixedImage, movingImage, color.overlay = "jet", alpha = 0.7 )
plot( movingImage, movingImageLM, color.overlay = "jet", alpha = 0.7 )

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
  regIterations = c( 1500, 1500, 50, 20, 10, 10, 10 ),
  verbose = TRUE, printArgs = TRUE, outprefix = outputPrefix,
  multivariateExtras = list(
    list( "meansquares", fixedImageLM1, movingImageLM1, 1, 16 ),
    list( "meansquares", fixedImageLM2, movingImageLM2, 1, 16 ) ) )
txlm = antsApplyTransforms( fixedImageLM, movingImageLM, registrationSyN$fwdtransforms,
  interpolator = 'nearestNeighbor' )
# Plot the fixed and warped moving image
layout( matrix(1:3,nrow=1))
plot( fixedImage, colorbar=FALSE )
plot( registrationSyN$warpedmovout, colorbar=FALSE   )
plot( fixedImage, txlm, alpha=0.5, colorbar=FALSE, doCropping=FALSE )
