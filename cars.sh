dim=2
m=beetle.jpg ;	f=ford.jpg
if [ ! -s $f ] ; then no fixed $f ; exit 1 ; fi 
if [ ! -s $m ] ; then no moving $m ; exit 1 ; fi 
its=[1500x1500x1500x300x100x0,1.e-7,5]
its2=[200x200x200x200x150x50,0,5]
smth=5x4x3x2x1x0
down=7x6x5x4x2x1
tx=" syn[ 0.25 , 3.0, 1 ] "
if [[ ! -s b2f_0GenericAffine.mat ]] ; then 
antsRegistration -d $dim \
                        -m Mattes[  $f, $m , 1,  20, Random, 0.2 ] \
                         -t affine[ 2.0 ]  \
                         -c $its  \
                        -s $smth  \
                        -f $down \
                       -u 1 \
                       -o [b2f_,b2f_aff.nii.gz] 
fi

#                        -m cc[  $f, $m , 1, 8 ] \
antsRegistration -d $dim -r [b2f_0GenericAffine.mat] \
                        -m Mattes[  $f, $m , 1,  32 ] \
                        -t $tx \
                        -c $its2  \
                        -s $smth  \
                        -f $down \
                       -u 1 \
                       -o [b2f_,b2f_diff.nii.gz,b2f_diff_inv.nii.gz] 
MeasureImageSimilarity $dim 2 $f b2f_aff.nii.gz
MeasureImageSimilarity 2 2 $f b2f_diff.nii.gz log.txt 
ConvertImagePixelType b2f_aff.nii.gz b2f_aff.jpg 1 
ConvertImagePixelType b2f_diff.nii.gz b2f_diff.jpg 1 
