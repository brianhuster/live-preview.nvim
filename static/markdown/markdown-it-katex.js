// Optimized markdown-it plugin for KaTeX math rendering
// Based on vscode-markdown-it-katex approach

(function(global,factory){
    typeof exports==='object'&&typeof module!=='undefined'?module.exports=factory():
    typeof define==='function'&&define.amd?define(factory):
    (global=global||self,global.markdownitKatex=factory());
}(this,function(){
    'use strict';

    // Pre-compiled regex for better performance
    const RE_VALID_PREV=/[\w\d]/;
    const RE_VALID_NEXT=/[\w\d]/;
    const RE_NOT_WS=/\S/;

    function math_inline(state,silent){
        if(state.src.charCodeAt(state.pos)!==36)return false; // 36 is '$'

        const prev=state.src[state.pos-1];
        if(prev&&RE_NOT_WS.test(prev)&&RE_VALID_PREV.test(prev))return false;

        const start=state.pos+1;
        let match=start;
        const src=state.src;
        const len=src.length;

        while(match<len){
            match=src.indexOf('$',match);
            if(match===-1)return false;

            let esc=match-1,escCount=0;
            while(esc>=0&&src.charCodeAt(esc)===92){escCount++;esc--;}
            if((escCount&1)===0)break;
            match++;
        }

        if(match>=len)return false;

        const next=src[match+1];
        if(next&&RE_VALID_NEXT.test(next))return false;

        if(!silent){
            const token=state.push('math_inline','math',0);
            token.markup='$';
            token.content=src.slice(start,match);
        }

        state.pos=match+1;
        return true;
    }

    function math_block(state,start,end,silent){
        const pos=state.bMarks[start]+state.tShift[start];
        if(pos+2>state.eMarks[start])return false;

        const src=state.src;
        if(src.charCodeAt(pos)!==36||src.charCodeAt(pos+1)!==36)return false;

        const lineStart=pos+2;
        const lineEnd=state.eMarks[start];
        let firstLine=src.slice(lineStart,lineEnd);

        const trimmed=firstLine.trim();
        const dblIdx=trimmed.lastIndexOf('$$');

        if(dblIdx===trimmed.length-2){
            if(!silent){
                const token=state.push('math_block','math',0);
                token.block=true;
                token.content=trimmed.slice(0,dblIdx);
                token.markup='$$';
            }
            state.line=start+1;
            return true;
        }

        let next=start+1;
        let lastLine='';

        for(;next<end;next++){
            const p=state.bMarks[next]+state.tShift[next];
            const line=src.slice(p,state.eMarks[next]).trim();
            if(line.endsWith('$$')){
                lastLine=line.slice(0,-2);
                break;
            }
        }

        if(next>=end)return false;

        if(!silent){
            const token=state.push('math_block','math',0);
            token.block=true;
            token.content=(firstLine?firstLine+'\n':'')+
                         state.getLines(start+1,next,state.tShift[start],true)+
                         lastLine;
            token.markup='$$';
            token.map=[start,state.line];
        }

        state.line=next+1;
        return true;
    }

    function renderKatex(content,displayMode){
        try{
            return katex.renderToString(content,{throwOnError:false,displayMode});
        }catch(e){
            return displayMode
                ?`<div class="katex-display katex-error">${content}</div>`
                :`<span class="katex-error">${content}</span>`;
        }
    }

    return function markdown_it_katex(md){
        md.inline.ruler.after('escape','math_inline',math_inline);
        md.block.ruler.after('blockquote','math_block',math_block,{
            alt:['paragraph','reference','blockquote','list']
        });

        md.renderer.rules.math_inline=(tokens,idx)=>renderKatex(tokens[idx].content,false);
        md.renderer.rules.math_block=(tokens,idx)=>`<div class="katex-display">${renderKatex(tokens[idx].content,true)}</div>`;
    };
}));