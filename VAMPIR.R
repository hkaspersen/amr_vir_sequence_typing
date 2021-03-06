#!/usr/bin/env Rscript

###########################################################
######################### VAMPIR ##########################
###########################################################

# This script takes multiple input from the software
# ARIBA (github.com/sanger-pathogens/ariba) and
# create summary reports and visualizations. One
# can select specific analyses based on the data you
# have: AMR, virulence, MLST or plasmids.

# Author: Håkon Kaspersen

###########################################################
###########################################################
###########################################################

# ------------------- Libraries --------------------
suppressPackageStartupMessages(library(optparse))
parser <- OptionParser(usage = "Usage: %prog [options] -o output_folder")

# Create command line options
parser <- add_option(parser,
                     c("-u", "--mut"),
                     action = "store",
                     help = "Directory of megaRes reports.")
parser <- add_option(parser,
                     c("-a", "--acq"),
                     action = "store",
                     help = "Directory of resFinder reports.")
parser <- add_option(parser,
                     c("-i", "--intrinsic"),
                     action = "store",
                     help = "List of intrinsic genes of interest, used with -u. 
                     Type 'all' for including all reported genes.
                     Can partially match gene names, f. ex. 'gyr' will match all gyr genes identified.
                     Example: -i gyr,par,mar")
parser <- add_option(parser,
                     c("-q", "--gyrfix"),
                     action = "store_true",
                     help = "Add to filter the reported mutations in gyrA, gyrB, parC and parE to those in the QRDR only.")
parser <- add_option(parser,
                     c("-c", "--acquired"),
                     action = "store",
                     help = "List of acquired genes of interest, used with -a.
                     Type 'all' for including all reported genes.
                     Can partially match gene names, f. ex. 'qnr' will match all qnr genes identified.
                     Example: -c blaTEM,oqxAB,qnr")
parser <- add_option(parser,
                     c("-v", "--vir"),
                     action = "store",
                     help = "Directory of ARIBA virulence reports.")
parser <- add_option(parser,
                     c("-r","--virgenes"),
                     action = "store",
                     help = "Virulence genes of interest, use with -v.
                     Type 'all' for including all reported genes.")
parser <- add_option(parser,
                     c("-d", "--database"),
                     action = "store",
                     help = "Virulence database used: virfinder or vfdb")
parser <- add_option(parser,
                     c("-m", "--mlst"),
                     action = "store",
                     help = "Directory of ARIBA MLST reports.")
parser <- add_option(parser,
                     c("-p", "--plasmid"),
                     action = "store",
                     help = "Directory of ARIBA plasmid reports.")
parser <- add_option(parser,
                     c("-o", "--output"),
                     action = "store",
                     help = "Output directory. 
                     One folder for each analysis will be created
                     at given location.")
parser <- add_option(parser,
                     c("-f", "--fileending"),
                     action = "store",
                     help = "Ending suffix of result files from ARIBA.")
parser <- add_option(parser,
                     "--version",
                     action = "store_true",
                     help = "Print version info.")
opt <- parse_args(parser)

# Print version info
if (!is.null(opt$version)) {
  vi <- R.Version()
  print(paste0("VAMPIR ",
               system('git describe --tags --abbrev=0',
                      intern = TRUE),
               " run on ",
               vi$version.string))
  quit()
}

# Check if output folder is specified
if (is.null(opt$output)) {
  print("Please specify an output directory.")
  quit()
}

## ------------------- Tracks ----------------------
## Intrinsic AMR genes track
if (!is.null(opt$mut)) {
  if (is.null(opt$intrinsic)) {
    print("Please specify genes of interest with -i.")
    stop()
  } else if (is.null(opt$fileending)) {
    print("Please specify the file endings of input files with -f.")
    stop()
  } else {
    print(paste0(
      "Running intrinsic AMR gene summary analysis. Reports location: ",
    normalizePath(opt$mut, winslash = "/", mustWork = TRUE),
    ". Output location: ",
    normalizePath(opt$out, winslash = "/", mustWork = TRUE)))
  system(paste("Rscript /cluster/projects/nn9305k/vi_src/VAMPIR/src/intrinsic_script.R",
               opt$mut, 
               opt$out,
               opt$intrinsic,
               opt$fileending,
               opt$gyrfix))
  }
}

## Acquired AMR genes track
if (!is.null(opt$acq)) {
  if (is.null(opt$acquired)) {
    print("Please specify genes of interest with -c.")
    stop()
  } else if (is.null(opt$fileending)) {
    print("Please specify the file endings of input files with -f.")
    stop()
  } else {
    print(paste0(
      "Running acquired AMR gene summary analysis. Reports location: ",
    normalizePath(opt$acq, winslash = "/", mustWork = TRUE),
    ". Output location: ",
    normalizePath(opt$out, winslash = "/", mustWork = TRUE)))
  system(paste("Rscript /cluster/projects/nn9305k/vi_src/VAMPIR/src/acquired_script.R",
               opt$acq, 
               opt$out, 
               opt$acquired,
               opt$fileending))
  }
}

## Virulence gene track
if (!is.null(opt$vir)) {
  if (is.null(opt$database)) {
    print("Please specify virulence database used: virfinder, vfdb or vfdb_core.")
    stop()
  }
  if (is.null(opt$virgenes)) {
    print("Please specify virulence genes with -r.")
    stop()
  } else if (is.null(opt$fileending)) {
    print("Please specify the file endings of input files with -f.")
    stop()
  } else {
    print(paste0(
      "Running virulence gene summary analysis. Reports location: ",
      normalizePath(opt$vir, winslash = "/", mustWork = TRUE),
      ". Output location: ",
      normalizePath(opt$out, winslash = "/", mustWork = TRUE),
      ". Virulence database: ",
      opt$database))
    system(paste("Rscript /cluster/projects/nn9305k/vi_src/VAMPIR/src/vir_script.R",
                 opt$vir,
                 opt$database,
                 opt$virgenes,
                 opt$out,
                 opt$fileending)) 
  }
}

## MLST track
if (!is.null(opt$mlst)) {
  if (is.null(opt$fileending)) {
  print("Please specify the file endings of input files with -f.")
  stop()
  } else {
    print(paste0(
      "Running MLST summary analysis. Reports location: ", 
      normalizePath(opt$mlst, winslash = "/", mustWork = TRUE),
      ". Output location: ",
      normalizePath(opt$out, winslash = "/", mustWork = TRUE)))
    system(paste("Rscript /cluster/projects/nn9305k/vi_src/VAMPIR/src/mlst_script.R",
                 opt$mlst,
                 opt$out,
                 opt$fileending)) 
  }
}

## Plasmid typing track
if (!is.null(opt$plasmid)) {
  if (is.null(opt$fileending)) {
    print("Please specify the file endings of input files with -f.")
    stop()
  } else {
  print(paste0(
    "Running plasmid summary analysis. Reports location: ",
    normalizePath(opt$plasmid, winslash = "/", mustWork = TRUE),
    ". Output location: ",
    normalizePath(opt$out, winslash = "/", mustWork = TRUE)))
  system(paste("Rscript /cluster/projects/nn9305k/vi_src/VAMPIR/src/plasmid_script.R",
               opt$plasmid,
               opt$out,
               opt$fileending))
  }
}