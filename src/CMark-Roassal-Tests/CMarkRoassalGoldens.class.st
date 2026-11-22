"
I hold the golden structural dumps of the renderings of the hand-built document of CMarkRoassalExamples and of the fixtures of CMarkFixtures (parsed with the GitHub options and footnotes), for CMarkRoassalGoldenTest: one line per shape, indented by its depth, with its class, the typeName of its model, its bounds rounded to 0.5 (left top right bottom) and the text of a label (non-ASCII characters escaped).  They were generated once and reviewed; regenerate them only for an intended change of the layout, and review the diff.  Their bounds hold the text metrics of the cairo of cairoVersion, the one that this repository's VM builds (the structure holds under any cairo).
"
Class {
	#name : 'CMarkRoassalGoldens',
	#superclass : 'Object',
	#category : 'CMark-Roassal-Tests-Support',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Support'
}

{ #category : 'accessing' }
CMarkRoassalGoldens class >> cairoVersion [
	"The version of the cairo that measured the labels of the goldens (CMarkRoassalGoldenTest compares the bounds under its major and minor version only)"

	^ '1.18.6'
]

{ #category : 'goldens' }
CMarkRoassalGoldens class >> footnotes [
	^ 'RSComposite document 0.0 0.0 672.0 115.5
  RSBox document 0.0 0.0 672.0 115.5
  RSBox document 0.0 0.0 672.0 115.5
  RSComposite paragraph 16.0 16.0 656.0 37.5
    RSBox paragraph 16.0 16.0 656.0 37.5
    RSLabel text 16.0 17.5 24.5 37.5 "A"
    RSLabel footnote_reference 24.5 16.0 37.0 31.0 "[1]"
    RSLabel text 41.0 17.5 65.5 37.5 "and"
    RSLabel footnote_reference 70.0 16.0 82.0 31.0 "[2]"
    RSLabel text 83.5 17.5 120.0 37.5 ", then"
    RSLabel footnote_reference 124.5 16.0 136.5 31.0 "[1]"
    RSLabel text 141.0 17.5 282.0 37.5 "again and [^missing]."
  RSBox document 16.0 47.5 656.0 48.5
  RSComposite footnote_definition 16.0 58.5 656.0 77.5
    RSBox footnote_definition 16.0 58.5 656.0 77.5
    RSLabel footnote_definition 21.0 58.5 31.0 77.5 "1."
    RSComposite paragraph 38.0 58.5 656.0 77.5
      RSBox paragraph 38.0 58.5 656.0 77.5
      RSLabel text 38.0 58.5 104.5 77.5 "The y note."
  RSComposite footnote_definition 16.0 80.5 656.0 99.5
    RSBox footnote_definition 16.0 80.5 656.0 99.5
    RSLabel footnote_definition 21.0 80.5 31.0 99.5 "2."
    RSComposite paragraph 38.0 80.5 656.0 99.5
      RSBox paragraph 38.0 80.5 656.0 99.5
      RSLabel text 38.0 80.5 104.5 99.5 "The x note."
'
]

{ #category : 'goldens' }
CMarkRoassalGoldens class >> handBuilt [
	^ 'RSComposite document 0.0 0.0 672.0 633.0
  RSBox document 0.0 0.0 672.0 633.0
  RSBox document 0.0 0.0 672.0 633.0
  RSComposite heading 16.0 16.0 656.0 63.0
    RSBox heading 16.0 16.0 656.0 63.0
    RSLabel text 16.0 16.0 307.5 56.0 "Hand-built Markdown"
    RSBox heading 16.0 62.0 656.0 63.0
  RSComposite paragraph 16.0 73.0 656.0 145.5
    RSBox paragraph 16.0 73.0 656.0 145.5
    RSLabel text 16.0 73.0 129.5 93.5 "A paragraph with"
    RSLabel text 133.5 73.0 197.5 93.5 "emphasis"
    RSLabel text 198.0 73.0 201.0 93.5 ","
    RSLabel text 205.0 73.0 277.5 93.5 "strong text"
    RSLabel text 277.5 73.0 280.5 93.5 ","
    RSLabel text 284.5 73.0 326.0 93.5 "struck"
    RSLabel text 326.0 73.0 329.0 93.5 ","
    RSBox code 333.0 73.0 437.0 94.0
    RSLabel code 337.0 74.0 432.5 93.0 "inline code"
    RSLabel text 440.5 73.0 476.5 93.5 "and a"
    RSLabel text 480.5 73.0 597.5 93.5 "link to cmark-gfm"
    RSLabel text 599.0 73.0 615.5 93.5 ". It"
    RSLabel text 16.0 97.0 575.0 117.0 "wraps at the width of the column, and an image without a file shows its placeholder:"
    RSComposite image 16.0 120.0 195.0 145.5
      RSBox image 16.0 120.0 195.0 145.5
      RSLabel image 20.5 122.5 190.5 143.0 "[image: a missing picture]"
    RSLabel text 195.0 122.0 198.0 142.5 "."
  RSComposite heading 16.0 155.5 656.0 193.5
    RSBox heading 16.0 155.5 656.0 193.5
    RSLabel text 16.0 155.5 64.5 186.5 "Lists"
    RSBox heading 16.0 192.5 656.0 193.5
  RSComposite list 16.0 203.5 656.0 339.5
    RSBox list 16.0 203.5 656.0 339.5
    RSComposite item 16.0 203.5 656.0 224.0
      RSBox item 16.0 203.5 656.0 224.0
      RSEllipse item 26.5 211.5 32.0 217.0
      RSComposite paragraph 38.0 203.5 656.0 224.0
        RSBox paragraph 38.0 203.5 656.0 224.0
        RSLabel text 38.0 203.5 88.0 224.0 "a bullet"
    RSComposite item 16.0 227.0 656.0 293.0
      RSBox item 16.0 227.0 656.0 293.0
      RSEllipse item 26.5 234.5 32.0 240.0
      RSComposite paragraph 38.0 227.0 656.0 247.0
        RSBox paragraph 38.0 227.0 656.0 247.0
        RSLabel text 38.0 227.0 261.0 247.0 "a bullet with a nested ordered list"
      RSComposite list 38.0 250.0 656.0 293.0
        RSBox list 38.0 250.0 656.0 293.0
        RSComposite item 38.0 250.0 656.0 270.0
          RSBox item 38.0 250.0 656.0 270.0
          RSLabel item 42.0 250.0 53.0 270.0 "3."
          RSComposite paragraph 60.0 250.0 656.0 270.0
            RSBox paragraph 60.0 250.0 656.0 270.0
            RSLabel text 60.0 250.0 91.0 270.0 "third"
        RSComposite item 38.0 273.0 656.0 293.0
          RSBox item 38.0 273.0 656.0 293.0
          RSLabel item 42.0 273.0 53.0 293.0 "4."
          RSComposite paragraph 60.0 273.0 656.0 293.0
            RSBox paragraph 60.0 273.0 656.0 293.0
            RSLabel text 60.0 273.0 100.5 293.0 "fourth"
    RSComposite tasklist 16.0 296.0 656.0 316.5
      RSBox tasklist 16.0 296.0 656.0 316.5
      RSBox tasklist 19.5 300.0 32.0 312.5
      RSPolyline tasklist 21.5 303.5 30.0 310.0
      RSComposite paragraph 38.0 296.0 656.0 316.5
        RSBox paragraph 38.0 296.0 656.0 316.5
        RSLabel text 38.0 296.0 114.5 316.5 "a done task"
    RSComposite tasklist 16.0 319.5 656.0 339.5
      RSBox tasklist 16.0 319.5 656.0 339.5
      RSBox tasklist 19.0 322.5 32.5 336.5
      RSComposite paragraph 38.0 319.5 656.0 339.5
        RSBox paragraph 38.0 319.5 656.0 339.5
        RSLabel text 38.0 319.5 123.5 339.5 "an open task"
  RSComposite block_quote 16.0 349.5 656.0 369.5
    RSBox block_quote 16.0 349.5 656.0 369.5
    RSBox block_quote 16.0 349.5 20.0 369.5
    RSComposite paragraph 32.0 349.5 656.0 369.5
      RSBox paragraph 32.0 349.5 656.0 369.5
      RSLabel text 32.0 349.5 419.0 369.5 "A block quote is muted and indented, with a bar on its left."
  RSComposite code_block 16.0 379.5 656.0 437.0
    RSBox code_block 16.0 379.5 656.0 437.0
    RSBox code_block 16.0 379.5 656.0 437.0
    RSLabel code_block 26.0 389.5 243.0 408.5 "Transcript show: ''hello'';"
    RSLabel code_block 26.0 408.5 84.5 427.0 "    cr."
    RSLabel code_block 605.0 381.5 651.0 396.5 "smalltalk"
  RSComposite table 15.5 446.5 230.0 533.0
    RSBox table 16.0 447.0 229.5 532.5
    RSComposite table_header 15.5 446.5 230.0 476.0
      RSBox table_header 16.0 447.0 229.5 475.5
      RSComposite table_cell 15.5 446.5 109.5 476.0
        RSBox table_cell 16.0 447.0 109.0 475.5
        RSBox table_cell 15.5 446.5 109.5 476.0
        RSLabel text 22.0 451.0 48.5 471.5 "Left"
      RSComposite table_cell 108.5 446.5 166.0 476.0
        RSBox table_cell 109.0 447.0 165.5 475.5
        RSBox table_cell 108.5 446.5 166.0 476.0
        RSLabel text 115.0 451.0 159.5 471.5 "Centre"
      RSComposite table_cell 165.0 446.5 230.0 476.0
        RSBox table_cell 165.5 447.0 229.5 475.5
        RSBox table_cell 165.0 446.5 230.0 476.0
        RSLabel text 188.0 451.0 224.0 471.5 "Right"
    RSComposite table_row 15.5 475.0 230.0 504.0
      RSBox table_row 16.0 475.5 229.5 503.5
      RSComposite table_cell 15.5 475.0 109.5 504.0
        RSBox table_cell 16.0 475.5 109.0 503.5
        RSBox table_cell 15.5 475.0 109.5 504.0
        RSLabel text 22.0 479.5 29.0 499.5 "a"
      RSComposite table_cell 108.5 475.0 166.0 504.0
        RSBox table_cell 109.0 475.5 165.5 503.5
        RSBox table_cell 108.5 475.0 166.0 504.0
        RSLabel text 133.0 479.5 141.0 499.5 "b"
      RSComposite table_cell 165.0 475.0 230.0 504.0
        RSBox table_cell 165.5 475.5 229.5 503.5
        RSBox table_cell 165.0 475.0 230.0 504.0
        RSLabel text 195.5 479.5 222.5 499.5 "1.50"
    RSComposite table_row 15.5 503.0 230.0 533.0
      RSBox table_row 16.0 503.5 229.5 532.5
      RSComposite table_cell 15.5 503.0 109.5 533.0
        RSBox table_cell 16.0 503.5 109.0 532.5
        RSBox table_cell 15.5 503.0 109.5 533.0
        RSLabel text 22.0 507.5 102.5 527.5 "a longer cell"
      RSComposite table_cell 108.5 503.0 166.0 533.0
        RSBox table_cell 109.0 503.5 165.5 532.5
        RSBox table_cell 108.5 503.0 166.0 533.0
        RSBox code 129.5 507.5 145.5 528.5
        RSLabel code 133.0 508.5 140.5 527.5 "x"
      RSComposite table_cell 165.0 503.0 230.0 533.0
        RSBox table_cell 165.5 503.5 229.5 532.5
        RSBox table_cell 165.0 503.0 230.0 533.0
        RSLabel text 171.5 507.5 222.5 527.5 "1234.00"
  RSComposite thematic_break 16.0 542.5 656.0 545.5
    RSBox thematic_break 16.0 542.5 656.0 545.5
    RSBox thematic_break 16.0 542.5 656.0 545.5
  RSComposite paragraph 16.0 555.5 656.0 577.0
    RSBox paragraph 16.0 555.5 656.0 577.0
    RSLabel text 16.0 557.0 152.5 577.0 "A footnote reference"
    RSLabel footnote_reference 153.0 555.5 165.0 570.5 "[1]"
    RSLabel text 169.5 557.0 363.0 577.0 "points at the end of the page."
  RSBox document 16.0 587.0 656.0 588.0
  RSComposite footnote_definition 16.0 598.0 656.0 617.0
    RSBox footnote_definition 16.0 598.0 656.0 617.0
    RSLabel footnote_definition 21.0 598.0 31.0 617.0 "1."
    RSComposite paragraph 38.0 598.0 656.0 617.0
      RSBox paragraph 38.0 598.0 656.0 617.0
      RSLabel text 38.0 598.0 185.0 617.0 "The text of the footnote."
'
]

{ #category : 'goldens' }
CMarkRoassalGoldens class >> nested [
	^ 'RSComposite document 0.0 0.0 672.0 167.5
  RSBox document 0.0 0.0 672.0 167.5
  RSBox document 0.0 0.0 672.0 167.5
  RSComposite block_quote 16.0 16.0 656.0 151.5
    RSBox block_quote 16.0 16.0 656.0 151.5
    RSBox block_quote 16.0 16.0 20.0 151.5
    RSComposite list 32.0 16.0 656.0 151.5
      RSBox list 32.0 16.0 656.0 151.5
      RSComposite item 32.0 16.0 656.0 151.5
        RSBox item 32.0 16.0 656.0 151.5
        RSLabel item 36.0 16.0 47.0 36.0 "1."
        RSComposite paragraph 54.0 16.0 656.0 36.0
          RSBox paragraph 54.0 16.0 656.0 36.0
          RSLabel text 54.0 16.0 79.0 36.0 "one"
        RSComposite block_quote 54.0 39.0 656.0 59.0
          RSBox block_quote 54.0 39.0 656.0 59.0
          RSBox block_quote 54.0 39.0 58.0 59.0
          RSComposite paragraph 70.0 39.0 656.0 59.0
            RSBox paragraph 70.0 39.0 656.0 59.0
            RSLabel text 70.0 39.0 117.0 59.0 "quoted"
            RSLabel text 121.5 39.0 133.0 59.0 "in"
            RSLabel text 137.5 39.0 145.0 59.0 "a"
            RSLabel text 149.0 39.0 174.0 59.0 "link"
            RSLabel text 176.5 39.0 206.0 59.0 "here"
        RSComposite list 54.0 62.0 656.0 151.5
          RSBox list 54.0 62.0 656.0 151.5
          RSComposite item 54.0 62.0 656.0 151.5
            RSBox item 54.0 62.0 656.0 151.5
            RSEllipse item 64.5 70.0 70.0 75.5
            RSComposite paragraph 76.0 62.0 656.0 82.5
              RSBox paragraph 76.0 62.0 656.0 82.5
              RSLabel text 76.0 62.0 83.0 82.5 "a"
            RSComposite list 76.0 85.5 656.0 151.5
              RSBox list 76.0 85.5 656.0 151.5
              RSComposite item 76.0 85.5 656.0 151.5
                RSBox item 76.0 85.5 656.0 151.5
                RSEllipse item 86.0 92.5 92.5 99.0
                RSComposite paragraph 98.0 85.5 656.0 105.5
                  RSBox paragraph 98.0 85.5 656.0 105.5
                  RSLabel text 98.0 85.5 106.0 105.5 "b"
                RSComposite list 98.0 108.5 656.0 151.5
                  RSBox list 98.0 108.5 656.0 151.5
                  RSComposite item 98.0 108.5 656.0 151.5
                    RSBox item 98.0 108.5 656.0 151.5
                    RSBox item 109.0 116.5 113.5 121.5
                    RSComposite paragraph 120.0 108.5 656.0 128.5
                      RSBox paragraph 120.0 108.5 656.0 128.5
                      RSLabel text 120.0 108.5 127.0 128.5 "c"
                    RSComposite list 120.0 131.5 656.0 151.5
                      RSBox list 120.0 131.5 656.0 151.5
                      RSComposite item 120.0 131.5 656.0 151.5
                        RSBox item 120.0 131.5 656.0 151.5
                        RSEllipse item 130.5 139.5 136.0 145.0
                        RSComposite paragraph 142.0 131.5 656.0 151.5
                          RSBox paragraph 142.0 131.5 656.0 151.5
                          RSLabel text 142.0 131.5 149.5 151.5 "d"
'
]

{ #category : 'goldens' }
CMarkRoassalGoldens class >> sample [
	^ 'RSComposite document 0.0 0.0 672.0 639.0
  RSBox document 0.0 0.0 672.0 639.0
  RSBox document 0.0 0.0 672.0 639.0
  RSComposite heading 16.0 16.0 656.0 63.0
    RSBox heading 16.0 16.0 656.0 63.0
    RSLabel text 16.0 16.0 129.0 56.0 "Heading"
    RSLabel text 134.5 16.0 185.5 56.0 "one"
    RSBox heading 16.0 62.0 656.0 63.0
  RSComposite heading 16.0 73.0 656.0 111.5
    RSBox heading 16.0 73.0 656.0 111.5
    RSLabel text 16.0 73.0 175.0 104.5 "Setext heading"
    RSBox heading 16.0 110.5 656.0 111.5
  RSComposite paragraph 16.0 121.5 656.0 194.5
    RSBox paragraph 16.0 121.5 656.0 194.5
    RSLabel text 16.0 123.5 54.0 144.0 "Some"
    RSLabel text 57.5 123.5 121.5 144.0 "emphasis"
    RSLabel text 122.0 123.5 125.0 144.0 ","
    RSLabel text 129.0 123.5 172.5 144.0 "strong"
    RSLabel text 172.0 123.5 175.5 144.0 ","
    RSLabel text 179.5 123.5 221.0 144.0 "struck"
    RSLabel text 221.0 123.5 224.0 144.0 ","
    RSBox code 228.0 123.5 270.5 144.5
    RSLabel code 231.5 124.5 266.0 143.5 "code"
    RSLabel text 270.5 123.5 284.5 144.0 ", a"
    RSLabel text 289.0 123.5 313.5 144.0 "link"
    RSLabel text 317.0 123.5 361.5 144.0 "and an"
    RSComposite image 365.5 121.5 472.5 147.0
      RSBox image 365.5 121.5 472.5 147.0
      RSLabel image 370.0 124.0 468.0 144.5 "[image: image]"
    RSLabel text 472.5 123.5 541.5 144.0 ", autolinks"
    RSLabel text 545.5 123.5 649.5 144.0 "www.pharo.org"
    RSLabel text 16.0 150.0 40.5 170.0 "and"
    RSLabel text 45.0 150.0 113.5 170.0 "https://x.y"
    RSLabel text 114.0 150.0 117.0 170.0 ","
    RSLabel text 121.0 150.0 205.0 170.0 "a hard break"
    RSLabel text 16.0 174.5 69.5 194.5 "and raw"
    RSLabel text 73.0 174.5 104.0 194.5 "html"
    RSLabel text 104.5 174.5 172.5 194.5 ". Footnote"
    RSLabel footnote_reference 173.5 173.0 185.5 188.0 "[1]"
    RSLabel text 186.5 174.5 189.5 194.5 "."
  RSComposite block_quote 16.0 204.5 656.0 224.5
    RSBox block_quote 16.0 204.5 656.0 224.5
    RSBox block_quote 16.0 204.5 20.0 224.5
    RSComposite paragraph 32.0 204.5 656.0 224.5
      RSBox paragraph 32.0 204.5 656.0 224.5
      RSLabel text 32.0 204.5 155.0 224.5 "Block quote with a"
      RSLabel text 159.5 204.5 213.0 224.5 "lazy line"
  RSComposite list 16.0 234.5 656.0 347.0
    RSBox list 16.0 234.5 656.0 347.0
    RSComposite item 16.0 234.5 656.0 255.0
      RSBox item 16.0 234.5 656.0 255.0
      RSLabel item 20.0 234.5 31.0 255.0 "1."
      RSComposite paragraph 38.0 234.5 656.0 255.0
        RSBox paragraph 38.0 234.5 656.0 255.0
        RSLabel text 38.0 234.5 64.0 255.0 "first"
    RSComposite item 16.0 258.0 656.0 347.0
      RSBox item 16.0 258.0 656.0 347.0
      RSLabel item 20.0 258.0 31.0 278.0 "2."
      RSComposite paragraph 38.0 258.0 656.0 278.0
        RSBox paragraph 38.0 258.0 656.0 278.0
        RSLabel text 38.0 258.0 85.0 278.0 "second"
      RSComposite list 38.0 281.0 656.0 347.0
        RSBox list 38.0 281.0 656.0 347.0
        RSComposite item 38.0 281.0 656.0 301.0
          RSBox item 38.0 281.0 656.0 301.0
          RSEllipse item 48.5 289.0 54.0 294.0
          RSComposite paragraph 60.0 281.0 656.0 301.0
            RSBox paragraph 60.0 281.0 656.0 301.0
            RSLabel text 60.0 281.0 147.5 301.0 "nested bullet"
        RSComposite tasklist 38.0 304.0 656.0 324.0
          RSBox tasklist 38.0 304.0 656.0 324.0
          RSBox tasklist 41.0 307.5 54.5 321.0
          RSComposite paragraph 60.0 304.0 656.0 324.0
            RSBox paragraph 60.0 304.0 656.0 324.0
            RSLabel text 60.0 304.0 125.5 324.0 "open task"
        RSComposite tasklist 38.0 327.0 656.0 347.0
          RSBox tasklist 38.0 327.0 656.0 347.0
          RSBox tasklist 41.5 331.0 54.0 343.5
          RSPolyline tasklist 43.5 334.5 52.0 340.5
          RSComposite paragraph 60.0 327.0 656.0 347.0
            RSBox paragraph 60.0 327.0 656.0 347.0
            RSLabel text 60.0 327.0 125.5 347.0 "done task"
  RSComposite code_block 16.0 357.0 656.0 396.0
    RSBox code_block 16.0 357.0 656.0 396.0
    RSBox code_block 16.0 357.0 656.0 396.0
    RSLabel code_block 26.0 367.0 207.0 386.0 "Transcript show: ''hi''"
    RSLabel code_block 605.0 359.0 651.0 374.5 "smalltalk"
  RSComposite code_block 16.0 406.0 656.0 445.0
    RSBox code_block 16.0 406.0 656.0 445.0
    RSBox code_block 16.0 406.0 656.0 445.0
    RSLabel code_block 26.0 416.0 139.5 435.0 "indented code"
  RSComposite table 15.5 454.5 206.0 540.5
    RSBox table 16.0 455.0 205.5 540.0
    RSComposite table_header 15.5 454.5 206.0 483.5
      RSBox table_header 16.0 455.0 205.5 483.0
      RSComposite table_cell 15.5 454.5 54.5 483.5
        RSBox table_cell 16.0 455.0 54.0 483.0
        RSBox table_cell 15.5 454.5 54.5 483.5
        RSLabel text 22.0 459.0 48.5 479.0 "Left"
      RSComposite table_cell 53.5 454.5 111.0 483.5
        RSBox table_cell 54.0 455.0 110.5 483.0
        RSBox table_cell 53.5 454.5 111.0 483.5
        RSLabel text 60.0 459.0 104.5 479.0 "Centre"
      RSComposite table_cell 110.0 454.5 158.0 483.5
        RSBox table_cell 110.5 455.0 157.5 483.0
        RSBox table_cell 110.0 454.5 158.0 483.5
        RSLabel text 116.5 459.0 152.0 479.0 "Right"
      RSComposite table_cell 157.0 454.5 206.0 483.5
        RSBox table_cell 157.5 455.0 205.5 483.0
        RSBox table_cell 157.0 454.5 206.0 483.5
        RSLabel text 163.5 459.0 199.5 479.0 "None"
    RSComposite table_row 15.5 482.5 206.0 512.5
      RSBox table_row 16.0 483.0 205.5 512.0
      RSComposite table_cell 15.5 482.5 54.5 512.5
        RSBox table_cell 16.0 483.0 54.0 512.0
        RSBox table_cell 15.5 482.5 54.5 512.5
        RSLabel text 22.0 487.0 29.0 507.0 "a"
      RSComposite table_cell 53.5 482.5 111.0 512.5
        RSBox table_cell 54.0 483.0 110.5 512.0
        RSBox table_cell 53.5 482.5 111.0 512.5
        RSLabel text 77.5 487.0 86.5 507.0 "b"
      RSComposite table_cell 110.0 482.5 158.0 512.5
        RSBox table_cell 110.5 483.0 157.5 512.0
        RSBox table_cell 110.0 482.5 158.0 512.5
        RSBox code 135.5 487.0 151.5 508.0
        RSLabel code 139.5 488.0 147.0 507.0 "c"
      RSComposite table_cell 157.0 482.5 206.0 512.5
        RSBox table_cell 157.5 483.0 205.5 512.0
        RSBox table_cell 157.0 482.5 206.0 512.5
        RSLabel text 163.5 487.0 190.0 507.0 "d | e"
    RSComposite table_row 15.5 511.5 206.0 540.5
      RSBox table_row 16.0 512.0 205.5 540.0
      RSComposite table_cell 15.5 511.5 54.5 540.5
        RSBox table_cell 16.0 512.0 54.0 540.0
        RSBox table_cell 15.5 511.5 54.5 540.5
        RSLabel text 22.0 516.0 27.0 536.0 "f"
      RSComposite table_cell 53.5 511.5 111.0 540.5
        RSBox table_cell 54.0 512.0 110.5 540.0
        RSBox table_cell 53.5 511.5 111.0 540.5
      RSComposite table_cell 110.0 511.5 158.0 540.5
        RSBox table_cell 110.5 512.0 157.5 540.0
        RSBox table_cell 110.0 511.5 158.0 540.5
      RSComposite table_cell 157.0 511.5 206.0 540.5
        RSBox table_cell 157.5 512.0 205.5 540.0
        RSBox table_cell 157.0 511.5 206.0 540.5
  RSComposite html_block 16.0 550.0 656.0 570.0
    RSBox html_block 16.0 550.0 656.0 570.0
    RSLabel html_block 16.0 550.0 87.5 570.0 "html block"
  RSComposite thematic_break 16.0 580.0 656.0 583.0
    RSBox thematic_break 16.0 580.0 656.0 583.0
    RSBox thematic_break 16.0 580.0 656.0 583.0
  RSBox document 16.0 593.0 656.0 594.0
  RSComposite footnote_definition 16.0 604.0 656.0 623.0
    RSBox footnote_definition 16.0 604.0 656.0 623.0
    RSLabel footnote_definition 21.0 604.0 31.0 623.0 "1."
    RSComposite paragraph 38.0 604.0 656.0 623.0
      RSBox paragraph 38.0 604.0 656.0 623.0
      RSLabel text 38.0 604.0 147.0 623.0 "The footnote text."
'
]

{ #category : 'goldens' }
CMarkRoassalGoldens class >> table [
	^ 'RSComposite document 0.0 0.0 672.0 145.0
  RSBox document 0.0 0.0 672.0 145.0
  RSBox document 0.0 0.0 672.0 145.0
  RSComposite table 15.5 15.5 209.0 129.5
    RSBox table 16.0 16.0 208.5 129.0
    RSComposite table_header 15.5 15.5 209.0 44.5
      RSBox table_header 16.0 16.0 208.5 44.0
      RSComposite table_cell 15.5 15.5 127.0 44.5
        RSBox table_cell 16.0 16.0 126.5 44.0
        RSBox table_cell 15.5 15.5 127.0 44.5
        RSLabel text 22.0 20.0 61.5 40.0 "Name"
      RSComposite table_cell 126.0 15.5 170.0 44.5
        RSBox table_cell 126.5 16.0 169.5 44.0
        RSBox table_cell 126.0 15.5 170.0 44.5
        RSLabel text 132.5 20.0 163.0 40.0 "Kind"
      RSComposite table_cell 169.0 15.5 209.0 44.5
        RSBox table_cell 169.5 16.0 208.5 44.0
        RSBox table_cell 169.0 15.5 209.0 44.5
        RSLabel text 175.5 20.0 203.0 40.0 "Size"
    RSComposite table_row 15.5 43.5 209.0 73.5
      RSBox table_row 16.0 44.0 208.5 73.0
      RSComposite table_cell 15.5 43.5 127.0 73.5
        RSBox table_cell 16.0 44.0 126.5 73.0
        RSBox table_cell 15.5 43.5 127.0 73.5
        RSBox code 22.0 48.0 73.0 69.0
        RSLabel code 25.5 49.0 69.0 68.0 "CMark"
      RSComposite table_cell 126.0 43.5 170.0 73.5
        RSBox table_cell 126.5 44.0 169.5 73.0
        RSBox table_cell 126.0 43.5 170.0 73.5
        RSLabel text 133.5 48.0 163.0 68.0 "core"
      RSComposite table_cell 169.0 43.5 209.0 73.5
        RSBox table_cell 169.5 44.0 208.5 73.0
        RSBox table_cell 169.0 43.5 209.0 73.5
        RSLabel text 195.0 48.0 202.0 68.0 "1"
    RSComposite table_row 15.5 72.5 209.0 101.5
      RSBox table_row 16.0 73.0 208.5 101.0
      RSComposite table_cell 15.5 72.5 127.0 101.5
        RSBox table_cell 16.0 73.0 126.5 101.0
        RSBox table_cell 15.5 72.5 127.0 101.5
        RSLabel text 22.0 77.0 120.0 97.0 "CMark-Roassal"
      RSComposite table_cell 126.0 72.5 170.0 101.5
        RSBox table_cell 126.5 73.0 169.5 101.0
        RSBox table_cell 126.0 72.5 170.0 101.5
        RSLabel text 132.5 77.0 163.0 97.0 "view"
      RSComposite table_cell 169.0 72.5 209.0 101.5
        RSBox table_cell 169.5 73.0 208.5 101.0
        RSBox table_cell 169.0 72.5 209.0 101.5
        RSLabel text 187.0 77.0 202.0 97.0 "22"
    RSComposite table_row 15.5 100.5 209.0 129.5
      RSBox table_row 16.0 101.0 208.5 129.0
      RSComposite table_cell 15.5 100.5 127.0 129.5
        RSBox table_cell 16.0 101.0 126.5 129.0
        RSBox table_cell 15.5 100.5 127.0 129.5
        RSLabel text 22.0 105.0 57.0 125.0 "short"
      RSComposite table_cell 126.0 100.5 170.0 129.5
        RSBox table_cell 126.5 101.0 169.5 129.0
        RSBox table_cell 126.0 100.5 170.0 129.5
      RSComposite table_cell 169.0 100.5 209.0 129.5
        RSBox table_cell 169.5 101.0 208.5 129.0
        RSBox table_cell 169.0 100.5 209.0 129.5
'
]

{ #category : 'goldens' }
CMarkRoassalGoldens class >> tasks [
	^ 'RSComposite document 0.0 0.0 672.0 167.5
  RSBox document 0.0 0.0 672.0 167.5
  RSBox document 0.0 0.0 672.0 167.5
  RSComposite list 16.0 16.0 656.0 151.5
    RSBox list 16.0 16.0 656.0 151.5
    RSComposite tasklist 16.0 16.0 656.0 36.0
      RSBox tasklist 16.0 16.0 656.0 36.0
      RSBox tasklist 19.0 19.5 32.5 33.0
      RSComposite paragraph 38.0 16.0 656.0 36.0
        RSBox paragraph 38.0 16.0 656.0 36.0
        RSLabel text 38.0 16.0 156.0 36.0 "write the decoder"
    RSComposite tasklist 16.0 39.0 656.0 59.0
      RSBox tasklist 16.0 39.0 656.0 59.0
      RSBox tasklist 19.5 43.0 32.0 55.5
      RSPolyline tasklist 21.5 46.5 30.0 52.5
      RSComposite paragraph 38.0 39.0 656.0 59.0
        RSBox paragraph 38.0 39.0 656.0 59.0
        RSLabel text 38.0 39.0 132.5 59.0 "write the tests"
    RSComposite tasklist 16.0 62.0 656.0 128.5
      RSBox tasklist 16.0 62.0 656.0 128.5
      RSBox tasklist 19.5 66.0 32.0 79.0
      RSPolyline tasklist 21.5 69.5 30.0 76.0
      RSComposite paragraph 38.0 62.0 656.0 82.5
        RSBox paragraph 38.0 62.0 656.0 82.5
        RSLabel text 38.0 62.0 89.5 82.5 "commit"
      RSComposite list 38.0 85.5 656.0 128.5
        RSBox list 38.0 85.5 656.0 128.5
        RSComposite tasklist 38.0 85.5 656.0 105.5
          RSBox tasklist 38.0 85.5 656.0 105.5
          RSBox tasklist 41.0 89.0 54.5 102.5
          RSComposite paragraph 60.0 85.5 656.0 105.5
            RSBox paragraph 60.0 85.5 656.0 105.5
            RSLabel text 60.0 85.5 142.0 105.5 "nested open"
        RSComposite tasklist 38.0 108.5 656.0 128.5
          RSBox tasklist 38.0 108.5 656.0 128.5
          RSBox tasklist 41.5 112.5 54.0 125.0
          RSPolyline tasklist 43.5 115.5 52.0 122.0
          RSComposite paragraph 60.0 108.5 656.0 128.5
            RSBox paragraph 60.0 108.5 656.0 128.5
            RSLabel text 60.0 108.5 142.5 128.5 "nested done"
    RSComposite item 16.0 131.5 656.0 151.5
      RSBox item 16.0 131.5 656.0 151.5
      RSEllipse item 26.5 139.5 32.0 145.0
      RSComposite paragraph 38.0 131.5 656.0 151.5
        RSBox paragraph 38.0 131.5 656.0 151.5
        RSLabel text 38.0 131.5 104.0 151.5 "plain item"
'
]

{ #category : 'goldens' }
CMarkRoassalGoldens class >> unicode [
	^ 'RSComposite document 0.0 0.0 672.0 176.5
  RSBox document 0.0 0.0 672.0 176.5
  RSBox document 0.0 0.0 672.0 176.5
  RSComposite heading 16.0 16.0 656.0 63.0
    RSBox heading 16.0 16.0 656.0 63.0
    RSLabel text 16.0 16.0 155.0 56.0 "\u{DC}n\u{EF}c\u{F6}d\u{E9} \u{2713}"
    RSBox heading 16.0 62.0 656.0 63.0
  RSComposite paragraph 16.0 73.0 656.0 94.0
    RSBox paragraph 16.0 73.0 656.0 94.0
    RSLabel text 16.0 73.0 45.0 93.5 "Caf\u{E9}"
    RSLabel text 49.0 73.0 100.0 93.5 "\u{3053}\u{3093}\u{306B}\u{3061}\u{306F}"
    RSBox code 104.5 73.0 120.5 94.0
    RSLabel code 108.0 74.0 116.0 93.0 "\u{1F600}"
    RSLabel text 123.5 73.0 141.0 93.5 "\u{3B1}\u{3B2}"
  RSComposite table 15.5 103.5 69.5 161.0
    RSBox table 16.0 104.0 69.0 160.5
    RSComposite table_header 15.5 103.5 69.5 132.5
      RSBox table_header 16.0 104.0 69.0 132.0
      RSComposite table_cell 15.5 103.5 49.5 132.5
        RSBox table_cell 16.0 104.0 49.0 132.0
        RSBox table_cell 15.5 103.5 49.5 132.5
        RSLabel text 22.0 108.0 31.5 128.0 "\u{1F600}"
      RSComposite table_cell 48.5 103.5 69.5 132.5
        RSBox table_cell 49.0 104.0 69.0 132.0
        RSBox table_cell 48.5 103.5 69.5 132.5
        RSLabel text 55.0 108.0 63.0 128.0 "\u{E9}"
    RSComposite table_row 15.5 131.5 69.5 161.0
      RSBox table_row 16.0 132.0 69.0 160.5
      RSComposite table_cell 15.5 131.5 49.5 161.0
        RSBox table_cell 16.0 132.0 49.0 160.5
        RSBox table_cell 15.5 131.5 49.5 161.0
        RSLabel text 22.0 136.0 41.5 156.5 "\u{4E2D}\u{6587}"
      RSComposite table_cell 48.5 131.5 69.5 161.0
        RSBox table_cell 49.0 132.0 69.0 160.5
        RSBox table_cell 48.5 131.5 69.5 161.0
        RSLabel text 55.0 136.0 62.0 156.5 "x"
'
]
