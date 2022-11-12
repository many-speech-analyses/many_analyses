# ICPhS 2023 RMarkdown template

## About

This is an RMarkdown version of the ICPhS LaTeX template. 
It is, as far as I can tell, equivalent to the LaTeX template. 
If you notice any discrepancies, please contact me (joseph.casillas@rutgers.edu) or submit a pull request. 

**Official site**: http://www.icphs2023.org/  
**Based off of LaTeX template available here**: https://www.icphs2023.org/call-for-papers/  

## Use

Fork or download this repo and edit for your manuscript. Keep in mind the following: 

- All of the front matter (title, author, organization, email, etc.) is located in `includes/tex/doc_prefix.tex`. 
Edit this file with the details of your manuscript. 
- Modify the `master.Rmd` file with the main text of your paper. 
- You can add LaTeX packages in `includes/tex/header.tex` or in the front matter at the top of `master.Rmd`. 
- Include your `.bib` file in `includes/bib/`. 
- Your data/scripts can go in `includes/scripts/`. 
- The `icphs2019.sty` style file is located in `includes/tex/`. 
You probably should avoid modifying this in order to keep the correct ICPhS format (unless you really know what you are doing)
- When you knit the `master.Rmd` file it will produce `master.tex`, just in case the .tex file is needed for submission/publication/etc.
- If using `knitr` chunks to produce figures, use the option `fig.cap.top` to keep figure captions above the plots
