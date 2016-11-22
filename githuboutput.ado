*cap prog drop githuboutput
prog githuboutput
	syntax [anything]  [, language(str) all in(str) quiet Number(numlist max=1)] 
	cap qui summarize installable
	local N 1
	local max `r(max)'
	if "`max'" == "" local max 0
	
	if !missing("`debug'") {
		di as txt "{title:Part one is done!}"
	}
	// -----------------------------------------------------------------------
	// Drawing the output table
	// =======================================================================
	
	// make sure one of the observations is installable 
	if `c(N)' > 0 & `max' != 0 | `c(N)' > 0 & !missing("`all'") {
		di in text _n " {hline 80}" _n												///
		"  {bf:Repository}" _col(17) "{bf:Username}" _col(29) "{bf:Install}" 	///
		_col(38) "{bf:Description} "  _n 	///
		" {hline 80}"
		
		// limit the output
		if missing("`number'") local number `c(N)'
		
		while `N' <= `c(N)' & `N' <= `number' {
			
			// check the language
			if !missing("`language'") & "`language'" == language[`N'] |			///
			missing("`language'") {		
				if installable[`N'] == 1 | !missing("`all'") {
					local address : di address[`N']
					capture githubdependency `address'
					
					local pushed : di %tcCCYY-NN-DD pushed[`N']
					
					local short : di abbrev(name[`N'], 13) 
					
					tokenize `address', parse("/")
					local user : di abbrev(`"`1'"', 11) 
					
					local homepage : di homepage[`N']
					local homeabbrev : di abbrev(`"`homepage'"', 30)
				
					
					*local user : di address[`N']
					*local short : di abbrev(name[`N'], 15) 
					
					
					
					di `"  {bf:{browse "http://github.com/`address'":`short'}}"' ///
					_col(17) `"{browse "http://github.com/`1'":`user'}"' _c
					
					local install : di installable[`N']
					if "`install'" == "1" {
						di _col(29) "{stata github install `address':Install}" _c
					}
					else {
						*di _col(29) "" _c
						di _col(29) "({stata github install `address':{it:force}})" _c
					}
					
					// Description
					// ------------------------------------
					local score: di %5.0f score[`N']
					*if `score' > 100 {
					*	local score: di %5.0f score[`N']
					*}
					local star : di star[`N']
					local size : di kb[`N']
					local lang : di language[`N']
					
					// get label
	*				local valuelabel :label (language) `lang'
	*				if "`valuelabel'" != "" local lang `valuelabel'
			
					local description : di description[`N']
					local l : di length(`"`description'"')
					local n 1
					local end 1
					
					tokenize `"`macval(description)'"'
					local sentence "`1'"
					local c 2
					
					local len 0
					local len2 0

					while `l' > 0 & `"``c''"' != "" {
						while `len2' <= 44 & `"``c''"' != "" {
							local sentence : di `"`sentence' ``c''"'
							local len : di strlen(`"`sentence'"') 
							local c `++c'
							local sentence2 : di `"`sentence' "' `"``c''"'
							local len2 : di strlen(`"`sentence2'"') 
						}
						local l`n' : di `"`sentence'"'
						local sentence  //RESET
						local sentence2 //RESET
						local len2    0 //RESET
						local l = `l'-`len'
						local n `++n'
					}

					if `"`l1'"' != "" di _col(38) `"`l1'"'
					
					//Add the package size
					*if "`install'" == "1" & trim(`"`l1'"') != "" {
					if trim(`"`l1'"') != "" {
						di _col(29) "{it:`size'k}" _c
					}
					//else if "`install'" == "1" {
					else {
						local alternative 1
					}
					local l1 //RESET
					local m 2
					
					// continue with the description
					while `m' <= `n' {
						if `"`l`m''"' != "" di _col(37) `"`l`m''"' 
						local l`m' //RESET
						local m `++m'
					}
					
					// Add the Homepage
					// -----------------------------------------------------------
					if `"`homepage'"' != "" {
						di _col(38) `"homepage {browse "`homepage'":`homeabbrev'}"'
						local homepage //RESET
					}
					
					// Add the last update
					// -----------------------------------------------------------
					di _col(38) `"updated on `pushed'"'
					
					// Add the additional description
					// -----------------------------------------------------------
					di _col(38) "{bf:Hits:}" trim("`score'") _col(48) "{bf:Stars:}" 		///
					trim("`star'") _c 
					
					if !missing("`lang'") {
						di _col(58) "{bf:Lang:}" trim("`lang'") _c
					}	
					
					if `r(dependency)' == 1 {
						if "`alternative'" == "1" {
							di _col(74) `"({browse "http://github.com/`address'/blob/master/dependency.do":Depend})"' 
						}
						else {
							di _col(74) `"({browse "http://github.com/`address'/blob/master/dependency.do":Depend})"' _n
						}
					}	
					else {
						if "`alternative'" == "1" {
							di _col(75)  
						}
						else {
							di _col(75) _n 
						}
					}	
					
					//Add the package size if the description was empty
					if "`alternative'" == "1"  {
						di _col(29) "{it:`size'k}" _n
						local alternative //RESET
					}
				}
			}
			local N `++N'
		}
		
		di " {hline 80}"
	}
	else if missing("`quiet'") & "`savelang'" != "all" & "`in'" != "name,description,readme" {
		di as txt "repository {bf:`anything'} was not found for {bf:in(`in')} and {bf:language(`savelang')}" 
		di "try: {stata github search `anything', in(all) language(all) all}" 
	}
	else if missing("`quiet'") {
		di as txt "repository {bf:`anything'} was not found for {bf:in(`savein')} and {bf:language(`savelang')}" 
		if missing("`all'") {
			di "try: {stata github search `anything', in(all) language(all) all}" 
		}
	}
	
end

