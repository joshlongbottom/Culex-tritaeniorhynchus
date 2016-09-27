## script to download all mosquito genera data from gbif
## data is to be used as background data within the model

# clear workspace
rm(list = ls())

# load required packages
require(dismo)
require(plyr)

# download all mosquito genera from gbif!
Aedeomyia <- gbif('Aedeomyia', '')
Abraedes <- gbif('Abraedes', '')
Alanstonea <- gbif('Alanstonea', '')
Albuginosus <- gbif('Albuginosus', '')
Armigeres <- gbif('Armigeres', '')
Ayurakitia <- gbif('Ayurakitia', '')
Aztecaedes <- gbif('Aztecaedes', '')
Belkinius <- gbif('Belkinius', '')
Borichinda <- gbif('Borichinda', '')
Bothaella <- gbif('Bothaella', '')
Bruceharrisonius <- gbif('Bruceharrisonius', '')
Christophersiomyia <- gbif('Christophersiomyia', '')
Collessius <- gbif('Collessius', '')
Alloeomyia <- gbif('Alloeomyia', '')
Dahliana <- gbif('Dahliana', '')
Danielsia <- gbif('Danielsia', '')
Diceromyia <- gbif('Diceromyia', '')
Dobrotworskyius <- gbif('Dobrotworskyius', '')
Downsiomyia <- gbif('Downsiomyia', '')
Edwardsaedes <- gbif('Edwardsaedes', '')
Eretmapodites <- gbif('Eretmapodites', '')
Finlaya <- gbif('Finlaya', '')
Fredwardsius <- gbif('Fredwardsius', '')
Georgecraigius <- gbif('Georgecraigius', '')
Horsfallius <- gbif('Horsfallius', '')
Gilesius <- gbif('Gilesius', '')
Gymnometopa <- gbif('Gymnometopa', '')
Haemagogus <- gbif('Haemagogus', '')
Halaedes <- gbif('Halaedes', '')
Heizmannia <- gbif('Heizmannia', '')
Himalaius <- gbif('Himalaius', '')
Hopkinsius <- gbif('Hopkinsius', '')
Yamada <- gbif('Yamada', '')
Howardina <- gbif('Howardina', '')
Huaedes <- gbif('Huaedes', '')
Hulecoeteomyia <- gbif('Hulecoeteomyia', '')
Indusius <- gbif('Indusius', '')
Isoaedes <- gbif('Isoaedes', '')
Jarnellius <- gbif('Jarnellius', '')
Lewnielsenius <- gbif('Lewnielsenius', '')
Jihlienius <- gbif('Jihlienius', '')
Kenknightia <- gbif('Kenknightia', '')
Kompia <- gbif('Kompia', '')
Leptosomatomyia <- gbif('Leptosomatomyia', '')
Lorrainea <- gbif('Lorrainea', '')
Luius <- gbif('Luius', '')
Macleaya <- gbif('Macleaya', '')
Molpemyia <- gbif('Molpemyia', '')
Mucidus <- gbif('Mucidus', '')
Neomelaniconion <- gbif('Neomelaniconion', '')
Ochlerotatus <- gbif('Ochlerotatus', '')
Opifex <- gbif('Opifex', '')
Paraedes <- gbif('Paraedes', '')
Patmarksia <- gbif('Patmarksia', '')
Phagomyia <- gbif('Phagomyia', '')
Pseudarmigeres <- gbif('Pseudarmigeres', '')
Psorophora <- gbif('Psorophora', '')
Rampamyia <- gbif('Rampamyia', '')
Scutomyia <- gbif('Scutomyia', '')
Skusea <- gbif('Skusea', '')
Stegomyia <- gbif('Stegomyia', '')
Tanakaius <- gbif('Tanakaius', '')
Tewarius <- gbif('Tewarius', '')
Udaya <- gbif('Udaya', '')
Vansomerenis <- gbif('Vansomerenis', '')
Verrallina <- gbif('Verrallina', '')
Zavortinkius <- gbif('Zavortinkius', '')
Zeugnomyia <- gbif('Zeugnomyia', '')
Deinocerites <- gbif('Deinocerites', '')
Galindomyia <- gbif('Galindomyia', '')
Lutzia <- gbif('Lutzia', '')
Culiseta <- gbif('Culiseta', '')
Ficalbia <- gbif('Ficalbia', '')
Mimomyia <- gbif('Mimomyia', '')
Hodgesia <- gbif('Hodgesia', '')
Coquillettidia <- gbif('Coquillettidia', '')
Mansonia <- gbif('Mansonia', '')
Mansonioides <- gbif('Mansonioides', '')
Orthopodomyia <- gbif('Orthopodomyia', '')
Isostomyia <- gbif('Isostomyia', '')
Johnbelkinia <- gbif('Johnbelkinia', '')
Kimia <- gbif('Kimia', '')
Limatus <- gbif('Limatus', '')
Malaya <- gbif('Malaya', '')
Maorigoeldia <- gbif('Maorigoeldia', '')
Onirion <- gbif('Onirion', '')
Runchomyia <- gbif('Runchomyia', '')
Sabethes <- gbif('Sabethes', '')
Shannoniana <- gbif('Shannoniana', '')
Topomyia <- gbif('Topomyia', '')
Trichoprosopon <- gbif('Trichoprosopon', '')
Tripteroides <- gbif('Tripteroides', '')
Wyeomyia <- gbif('Wyeomyia', '')
Toxorhynchites <- gbif('Toxorhynchites', '')
Uranotaenia <- gbif('Uranotaenia', '')

## bind all downloaded datasets together
# list all of the data frames in the environment
dfs <- Filter(function(x) is(x, "data.frame"), mget(ls()))

# rbind all dataframes in the list
genera <- rbind.fill(dfs)

# subset to remove any which are missing coordinates
genera <- genera[!is.na(genera$lat), ]

# reorder and subset gbif data to obtain variables of interest
names(genera)
genera$presence <- rep(NA, nrow(genera))
genera$admin_level <- rep(NA, nrow(genera))
genera$state <- rep(NA, nrow(genera))

genera <- genera[c(12, 86, 86, 154, 73, 49, 53, 156, 108, 51, 51, 155, 90)]

genera$source <- rep('gbif', nrow(genera))

names(genera) <- c('country',
                   'st_year',
                   'end_year',
                   'presence',
                   'species',
                   'lat',
                   'lon',
                   'state',
                   'county',
                   'locality',
                   'sitename',
                   'admin_level',
                   'coordinate_uncertainty',
                   'source')

# write out csv
write.csv(genera,
          'data/raw/background/gbif_genera.csv',
          row.names = FALSE)
