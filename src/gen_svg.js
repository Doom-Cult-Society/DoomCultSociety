const originalSvg = `<?xml version="1.0" encoding="UTF-8"?><svg viewBox="0 0 700 800" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style>.heavy,.superheavy{font:700 30px sans-serif;fill:#fff}</style><path d="M0 0h800v1000H0z"/><g transform="matrix(.1 0 0 -.1 -350 650)"><defs><g id="g"><circle cx="-20" cy="210" r="100"/><use xlink:href="#d"/><use transform="rotate(45 30.71 267.28)" xlink:href="#d"/><use transform="rotate(90 -20 240)" xlink:href="#d"/></g><g id="f"><use xlink:href="#c"/><use transform="rotate(45 -19.645 218.14)" xlink:href="#c"/><use transform="rotate(90 -30 230)" xlink:href="#c"/><use transform="rotate(-48 -37.302 218.45)" xlink:href="#c"/></g><g id="1"><use fill="#f57914" xlink:href="#l"/><use transform="matrix(.44463 1.2216 -1.0337 .37622 7471.6 -2470.6)" x="-2000" fill="#312b5d" xlink:href="#e"/></g><g id="2" transform="translate(5150 4100)"><use fill="#ed1c24" xlink:href="#g"/><use fill="#8c1b85" xlink:href="#f"/></g><g id="3"><use transform="scale(.9 -.7)" x="960" y="-4400" fill="#0994d3" xlink:href="#a"/><use transform="scale(.7 -.7) rotate(40 14283 5801)" fill="#ed1c24" xlink:href="#a"/></g><g id="4" transform="rotate(125 3495.9 1947) scale(.6)"><use fill="#f57914" xlink:href="#g"/><use fill="#8c1b85" xlink:href="#f"/></g><g id="5"><use transform="matrix(-1.4095 .51303 .0684 -1.4083 12071 6071.6)" x="-2100" y="1650" fill="#fff" xlink:href="#e"/><circle cx="6470" cy="1780" r="130" fill="#0994d3"/><circle cx="5770" cy="1350" r="70" fill="#ed1c24"/><circle cx="5820" cy="1150" r="70" fill="#ed1c24"/><circle cx="5720" cy="1550" r="70" fill="#ed1c24"/><circle cx="6190" cy="1700" r="80" fill="#ed1c24"/></g><g id="6"><circle cx="6e3" cy="1650" r="80" fill="#0994d3"/><circle cx="6370" cy="200" r="80" fill="#f57914"/><path d="m6300 1710c-7-13-6-26-4-41s9-26 17-37c6-11 22-17 41-24 17-4 44 9 79 41 35 33 63 131 85 299-92-124-153-194-183-207-4-2-9-4-13-6-10-4-17-13-22-24m-470-161c-26 2-50-6-72-26-19-17-33-39-39-65-4-13 20-164 72-452 50-286 181-530 393-731-201 421-292 709-277 860 15 150 20 247 13 284-6 37-17 68-28 90-15 24-37 39-61 41" fill="#ed1c24"/></g><g id="7"><use transform="scale(.9 1.6)" x="960" y="-840" fill="#0994d3" xlink:href="#a"/><use transform="rotate(-50 6340 4600)" fill="#fff" xlink:href="#h"/><use transform="scale(.9 1.3) rotate(30 6740 4300)" x="400" y="-530" fill="#ed1c24" xlink:href="#a"/></g><g id="8" transform="translate(7100 5100)"><use transform="rotate(260 -158.56 64.887) scale(.6)" fill="#ed1c24" xlink:href="#d"/><use transform="rotate(125) scale(.6)" xlink:href="#j"/><use transform="scale(-.6 .6) rotate(-55 -272.14 -141.67)" xlink:href="#j"/></g><g id="j"><use fill="#0994d3" xlink:href="#g"/><use fill="#8c1b85" xlink:href="#f"/></g><g id="l"><circle cx="5630" cy="4060" r="140"/><circle cx="5400" cy="3850" r="110"/><circle cx="5270" cy="3600" r="90"/><circle cx="5180" cy="3350" r="70"/><circle cx="5150" cy="3150" r="60"/></g><g id="q"><circle cx="6840" cy="3060" r="165" style="fill:#ed1344"/><circle cx="6770" cy="3335" r="165" style="fill:#ed1344"/><circle cx="6640" cy="3535" r="165" style="fill:#ed1344"/><circle cx="6395" cy="3690" r="165" style="fill:#ed1344"/><circle cx="6840" cy="3060" r="80" style="fill:#0994d3"/><circle cx="6770" cy="3335" r="80" style="fill:#0994d3"/><circle cx="6640" cy="3535" r="80" style="fill:#0994d3"/><circle cx="6395" cy="3690" r="80" style="fill:#0994d3"/></g><g id="p"><use xlink:href="#q"/><use xlink:href="#q" transform="rotate(180 6150 3060)"/><use xlink:href="#q" transform="rotate(270 6150 3060)"/><use xlink:href="#q" transform="rotate(90 6150 3060)"/></g><path id="n" d="m7507 5582c-168 33-340 50-517 52-177-2-349-20-517-52-345-68-659-244-941-530-284-286-469-556-556-814-20-57-35-116-50-175-33-138-48-284-46-436 0-452 74-803 220-1056 98-168 133-334 102-495-30-159 20-308 148-441 68-68 122-127 166-177 41-46 74-85 96-116 44-255 120-526 229-807 109-282 301-443 576-489 39-6 76-11 111-18 308-37 613-37 921 0 35 7 72 11 113 17 273 46 465 207 574 489 109 281 185 552 229 807 46 63 133 159 262 292s179 282 148 441c-30 161 4 327 103 495 146 253 220 605 223 1056-2 218-35 421-98 611-89 258-275 528-556 814-283 286-598 463-941 530" fill="#fcca07"/><path id="m" d="M7243 1429c-2 24-10 43-26 61-15 17-34 26-54 26h-67c-21 0-41-9-57-26-15-17-24-37-22-61v-260c-2-24 6-44 22-61 15-17 35-26 57-26h68c20 0 39 9 54 26s24 37 26 61v260m-9-487c-2 22-9 41-24 57-15 17-33 26-52 26h-65c-20 0-37-9-52-26-15-15-22-35-22-57V695c0-22 6-41 22-57 15-15 33-24 52-24h65c20 0 37 8 52 24 15 15 22 35 24 57v246m82 86c-15-20-22-39-22-63l.01-260c0-24 6-41 22-57 15-13 30-17 50-13l59 13c20 4 35 15 50 35 6 11 13 24 15.34 37 2 9 4 17 4 24v242c0 24-6 41-20 57-15 15-30 22-50 19m263 60h-59c-20 0-37-9-54-24-15-15-22-33-22-52V816c0-17 6-35 22-48 15-11 31-15 46-13h9l58 15c17 4 32 13 46 28 13 17 20 35 20 52v204c0 20-6 35-20 48-13 13-28 20-46 20m294 373c-11 11-24 17-39 17h-50c-17 0-33-6-48-20-13-13-20-28-20-48v-201c0-15 6-28 20-39 11-9 24-13 39-13h9l50 13c15 2 28 11 39 26s17 31 17 46v177c0 15-6 31-17 41m-480-65c0 22-7 41-20 57-15 18-30 26-48 26h-58c-20 0-37-9-52-26s-22-37-22-61v-260c0-24 6-43 22-59 15-15 33-20 52-17l59 6c17 2 33 13 48 33 13 17 20 37 20 59v242m381-262c-17-2-33-9-48-24-13-15-20-30-17-50V892c-2-15 4-28 17-37s26-13 41-11c2 2 4 2 6 2l52 17c15 7 28 15 39 31 11 15 17 33 17 48v178c0 15-6 28-17 39s-24 15-39 13l-52-4M7584 1488c-15-15-22-33-22-52v-229c0-20 6-35 22-48 13-11 28-15 44-13h11l57 15c17 4 33 13 48 28 13 17 20 35 20 52v203c0 19-6 35-20 48-15 13-30 20-48 20h-57c-20 0-39-9-55-24"/><path id="d" d="M0 0c4-54-1-112-17-177-9-40-18-73-31-103 7-32 21-61 36-83 28-48 53-71 78-73 22 4 39 31 54 81 8 34 12 75 11 115-19 22-36 47-51 74C43-107 14-51 0 0"/><path id="c" d="m250-340c41-36 75-48 96-40 21 12 25 46 14 95-5 30-15 59-28 88-8 17-14 37-25 56-8 17-20 34-30 54-44 68-91 124-140 163-20 16-40 28-55 36-15 4-27 7-37 4l-2-2c-4 0-7-5-9-7-7-9-10-21-12-38 0-14 1-30 6-52 12-58 40-124 83-194 5-7 12-13 17-20 10-19 23-40 39-57 28-33 56-63 85-86"/><path id="o" d="m5960 3720c-33 9-76 20-127 33-94 28-150 35-166 24-17-11-28-65-33-159-4-59-9-109-11-148-33-11-72-26-122-46-92-33-142-61-150-81-7-17 17-68 68-148 33-50 59-92 78-124-20-28-44-65-72-111-55-81-78-131-72-150 4-20 50-46 140-78 55-22 100-41 138-57 2-26 4-59 7-96v-35c4-98 15-153 31-164 15-11 68-6 161 17 57 15 105 26 142 35 22-26 50-61 83-103 61-76 102-113 122-116 20 0 59 37 120 109 37 46 68 85 94 113 33-7 76-20 129-35 94-24 148-33 166-22 15 11 26 65 33 159 0 15 0 28 2 39 2 41 4 79 6 107 33 13 74 28 124 48 92 35 140 61 146 79 6 20-17 68-68 148-33 50-57 92-76 124 18 30 41 68 72 111 52 81 76 131 72 150-6 20-52 48-142 81-54 22-100 39-135 54-2 35-4 78-6 133-4 98-15 153-30 164-15 13-70 6-161-17-59-15-107-26-144-35-22 26-50 61-83 103-61 76-100 116-120 116s-61-37-120-111c-37-46-70-83-96-111"/><path id="e" d="m6500 4100c-25 8-53 6-79-3-31-8-53-28-62-53-11-25-8-53 5-78 11-22 31-39 56-53 11-6 25-11 39-17 87-31 182-90 289-177-53 213-120 336-205 367-14 6-31 11-45 14"/><path id="h" d="m5769 4876c274 21 415 85 692-127-115 159-241 266-379 326-89 36-218 80-316 63-70-13-117-37-136-65-25-33-34-68-26-103s29-62 66-80c28-16 62-22 100-14"/><path id="a" d="m6740 4300c-17-22-25-48-28-78v-50c-3-98 34-230 109-401 62 168 93 303 92 400v50c-3 31-14 56-31 78-20 25-45 39-70 39-28 0-53-14-73-39"/><g id="i"><use transform="rotate(130 6130 3100)" fill="#9addf0" xlink:href="#l"/><circle cx="6665" cy="4440" r="80" fill="#0994d3"/><circle cx="6370" cy="4510" r="80" fill="#0994d3"/><circle cx="6480" cy="4360" r="60" fill="#0994d3"/><use fill="#0994d3" xlink:href="#a"/><circle cx="7e3" cy="3900" r="50" fill="#0994d3"/><use transform="rotate(-20 6500 4100)" x="110" y="50" fill="#ed1c24" xlink:href="#e"/><use fill="#ed1c24" xlink:href="#h"/><circle cx="5350" cy="2550" r="80" fill="#ed1c24"/><circle cx="5420" cy="2280" r="130" fill="#ed1c24"/><circle cx="5950" cy="4500" r="50" fill="#ed1c24"/><path d="m5844 4593c36 36 81 53 134 56 53 3 90-17 109-53 20-36 14-73-17-104-31-31-39-62-25-90 11-25 42-34 92-20 50 14 79 53 81 118 3 68-20 118-73 151-53 34-109 50-174 50-65 0-120-22-168-70-48-48-70-104-70-168 0-64 22-120 70-168 48-48 140-90 280-132 126-42 252-115 379-221-126 208-235 322-325 348-93 25-171 48-241 67-70 19-106 56-106 106 0 50 17 93 53 129" fill="#0994d3"/><circle cx="6160" cy="3050" r="600" fill="#312b5d"/><path d="m7145 1722c59 0 109 26 151 76 41 50 61 113 61 185s-19 135-61 185c-41 50-120 144-236 279-22 26-41 46-59 59-17-13-37-33-59-59-116-135-194-229-236-279-41-50-63-113-61-185-2-72 20-135 61-186 41-50 92-76 151-76 55 0 103 24 144 70" fill="#312b5d"/><use fill="#fff" xlink:href="#m"/><use xlink:href="#`;
const keywords = [
  '<use transform="',
  ' transform="',
  'rotate',
  ' fill="#f57914"',
  ' fill="#ed1c24"',
  ' fill="#8c1b85"',
  ' fill="#0994d3"',
  ' fill="#9addf0"',
  ' fill="#312b5d"',
  ' fill="#fff" ',
  'xlink:href="#',
  '<circle cx="',
  '<path id="',
  '"/><use ',
  '"><use ',
  '="http://www.w3.org/',
];

function findKeyword(input) {
  //console.log('foo = ', originalSvg.indexOf(keywords[3]));
  const lengths = keywords.map(k => k.length);
  const idxCounts = keywords.map(k => input.indexOf(k));

  const idx = idxCounts.reduce((iMin, x, i, arr) => {
    if (iMin == 99999 && x != -1) {
      return i;
    }
    if (iMin == 99999 && x == -1) {
      return iMin;
    }
    if (x != -1) {
      if (x < arr[iMin]) {
        return i;
      }
    }
    return iMin;
  }, 99999);

  return {
    name: idx != 99999 ? 't' + idx : '',
    len: idx != 99999 ? lengths[idx] : -1,
    offset: idx != 99999 ? idxCounts[idx] : -1,
  };
}

function parseSvg() {
  let yul = '';
  for (let i = 0; i < keywords.length; ++i) {
    yul += `let t${i} := '${keywords[i]}'\n`;
  }
  function addConstantString(yulIn, ptrIn, toAdd) {
    const len = toAdd.length;
    let yul = yulIn;
    let ptr = ptrIn;
    for (let i = 0; i < toAdd.length; i += 32) {
      const chunk = toAdd.substring(i, i + 32);
      yul += `mstore(${ptr}, '${chunk}')\n`;
      ptr += chunk.length;
    }
    return { yul, ptr };
  }
  let base = originalSvg;
  let ptr = 512;
  while (base.length > 0) {
    const { name, len, offset } = findKeyword(base);
    if (len == -1 || len == 0) {
      const res = addConstantString(yul, ptr, base);
      yul = res.yul;
      ptr = res.ptr;
      console.log(yul);
      break;
    }
    if (len > 0) {
      const res = addConstantString(yul, ptr, base.slice(0, offset));
      yul = res.yul;
      ptr = res.ptr;
      base = base.slice(offset);
      yul += `mstore(${ptr}, ${name})\n`;
      ptr += len;
      base = base.slice(len);
    }
  }
  console.log(yul);
  //   let count = (yul.match(/\n/g) || []).length;
  //   console.log(count);
}

parseSvg();
