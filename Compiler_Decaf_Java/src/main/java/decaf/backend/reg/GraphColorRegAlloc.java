package decaf.backend.reg;

import com.sun.jdi.event.StepEvent;
import decaf.backend.asm.AsmEmitter;
import decaf.backend.asm.HoleInstr;
import decaf.backend.asm.SubroutineEmitter;
import decaf.backend.asm.SubroutineInfo;
import decaf.backend.dataflow.BasicBlock;
import decaf.backend.dataflow.CFG;
import decaf.backend.dataflow.Loc;
import decaf.lowlevel.instr.PseudoInstr;
import decaf.lowlevel.instr.Reg;
import decaf.lowlevel.instr.Temp;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;

import java.util.*;

import static java.lang.System.exit;
import static java.lang.System.in;

/**
 * Brute force greedy register allocation algorithm.
 * <p>
 * To make our life easier, don't consider any special registers that may be used during call.
 */
public final class GraphColorRegAlloc extends RegAlloc {

    public GraphColorRegAlloc(AsmEmitter emitter) {
        super(emitter);
        for (var reg : emitter.allocatableRegs) {
            reg.used = false;
        }
    }

    // 着色图
    // 边表
    private Set<Pair<Temp, Temp>> edges = new TreeSet<Pair<Temp, Temp>>();
    // 相邻列表
    private Map<Temp, Set<Temp>> adjList = new TreeMap<>();
    // 边度数
    private Map<Temp, Integer> degree = new TreeMap<>();


    private void addEdge(Temp a, Temp b) {
        //孤立点情况
        if (a.compareTo(b) == 0) {
            //System.out.println("in single "+a+":"+b);
            if(!(a instanceof Reg) && !(adjList.containsKey(a))) {
                adjList.put(a,new TreeSet<>());
            }
        }
        if (!edges.contains(new ImmutablePair<>(a, b)) && a.compareTo(b) != 0) {
            //System.out.println("in pair "+a+":"+b);
            edges.add(new ImmutablePair<>(a, b));
            edges.add(new ImmutablePair<>(b, a));
            if (!(a instanceof Reg)) {
                if (adjList.containsKey(a)) {
                    adjList.get(a).add(b);
                } else {
                    adjList.put(a, new TreeSet<>());
                    adjList.get(a).add(b);
                }
                if (degree.containsKey(a)) {
                    degree.put(a, degree.get(a) + 1);
                } else {
                    degree.put(a, 1);
                }
            }
            if (!(b instanceof Reg)) {
                if (adjList.containsKey(b)) {
                    adjList.get(b).add(a);
                } else {
                    adjList.put(b, new TreeSet<>());
                    adjList.get(b).add(a);
                }
                if (degree.containsKey(b)) {
                    degree.put(b, degree.get(b) + 1);
                } else {
                    degree.put(b, 1);
                }
            }
            //System.out.println(adjList);
        }
    }


    @Override
    public void accept(CFG<PseudoInstr> graph, SubroutineInfo info) {
        var subEmitter = emitter.emitSubroutine(info);
        //System.out.println("in new func!");
        //构建干涉图
        edges.clear();
        adjList.clear();
        degree.clear();
        for (var bb : graph) {
            buildGraph(bb);
        }
        //分配寄存器
        AllocByColor();
        //填写到tac里面
        //首先确定需要填写的所有初始化变量
        inits.clear();
        for (var reg : emitter.allocatableRegs) {
            reg.used = false;
            reg.occupied = false;
        }
        for (var bb : graph) {
            findInits(bb);
        }
        //System.out.println("inits:"+inits+"  bindings:"+bindings);
        for(var temp: inits) {
            subEmitter.emitLoadFromStack(bindings.get(temp), temp);
            bindings.get(temp).occupied = true;
            bindings.get(temp).temp = temp;
        }
        for (var bb : graph) {
            bb.label.ifPresent(subEmitter::emitLabel);
            localAlloc(bb, subEmitter);
        }
        subEmitter.emitEnd();
    }

    private Map<Temp, Reg> bindings = new TreeMap<>();
    private TreeSet<Temp> inits = new TreeSet<>();

    private void bind(Temp temp, Reg reg) {
        //reg.used = true;

        bindings.put(temp, reg);
        //reg.occupied = true;
        reg.temp = temp;
    }

    private void unbind(Temp temp) {
        if (bindings.containsKey(temp)) {
            // bindings.get(temp).occupied = false;
            bindings.remove(temp);
        }
    }

    //     */
    private void findInits(BasicBlock<PseudoInstr> bb) {

        for (var loc : bb.allSeq()) {
            if(!(loc.instr instanceof HoleInstr)) {
                var instr = loc.instr;
                for (var i = 0; i < instr.srcs.length; i++) {
                    var temp = instr.srcs[i];
                    if (!(temp instanceof Reg)) {
                        var srcRegs = bindings.get(temp);
                        //System.out.println("src is " + temp + " " + srcRegs[i]);
                        if(!loc.liveIn.contains(temp) || !srcRegs.occupied || srcRegs.temp != temp) {
                            //System.out.println("load from stack:"+srcRegs[i]);
                            srcRegs.occupied = true;
                            srcRegs.temp = temp;
                            inits.add(temp);
                        }
                    } else {
                        ((Reg) temp).occupied = true;
                    }
                }

                for (var i = 0; i < instr.dsts.length; i++) {
                    var temp = instr.dsts[i];
                    if (temp instanceof Reg) {
                        ((Reg) temp).occupied = true;
                    } else {
                        var dstRegs = bindings.get(temp);
                        dstRegs.occupied = true;
                        dstRegs.temp = temp;
                    }
                    //System.out.println("dst func " + temp +":"+dstRegs[i]);
                }
            }
        }

        // Handle the last instruction, if it is a branch/return block.
        if (!bb.isEmpty() && !bb.kind.equals(BasicBlock.Kind.CONTINUOUS)) {
            var loc = bb.locs.get(bb.locs.size() - 1);
            var instr = loc.instr;
            for (var i = 0; i < instr.srcs.length; i++) {
                var temp = instr.srcs[i];
                if (!(temp instanceof Reg)) {
                    var srcRegs = bindings.get(temp);
                    //System.out.println("src is " + temp + " " + srcRegs[i]);
                    if(!loc.liveIn.contains(temp) || !srcRegs.occupied || srcRegs.temp != temp) {
                        //System.out.println("load from stack:"+srcRegs[i]);
                        srcRegs.occupied = true;
                        srcRegs.temp = temp;
                        inits.add(temp);
                    }
                } else {
                    ((Reg) temp).occupied = true;
                }
            }

            for (var i = 0; i < instr.dsts.length; i++) {
                var temp = instr.dsts[i];
                if (temp instanceof Reg) {
                    ((Reg) temp).occupied = true;
                } else {
                    var dstRegs = bindings.get(temp);
                    dstRegs.occupied = true;
                    dstRegs.temp = temp;
                }
                //System.out.println("dst func " + temp +":"+dstRegs[i]);
            }
        }
    }

    /**
     * build graph for basic block
     */

    private void buildGraph(BasicBlock<PseudoInstr> bb) {
        int count = 0;
        var templive = new TreeSet<Temp>();
        for (var loc : bb.allSeq()) {
            if(count == 0) {
                count++;
                var live = loc.liveIn;
                for (var temp1 : live) {
                    for (var temp2 : live) {
                        addEdge(temp1, temp2);
                        //System.out.println("add edge:" + temp1+":"+temp2);
                    }
                }
            }
            templive.addAll(loc.liveOut);
            templive.removeAll(loc.liveIn);
            for (var temp1 : templive) {
                for (var temp2 : loc.liveOut) {
                    addEdge(temp1, temp2);
                    //System.out.println("add edge:" + temp1+":"+temp2);
                }
            }
        }
    }

    /**
     * distribute registers
     */

    private void AllocByColor() {
        bindings.clear();
        for (var reg : emitter.allocatableRegs) {
            reg.used = false;
            reg.occupied = false;
        }
        Stack<Temp> checkPointStack = new Stack<>();
        Stack<Set<Temp>> checkEdgeStack = new Stack<>();
        int num = emitter.allocatableRegs.length;
        //System.out.println("keys:"+adjList.keySet()+"\nlength:"+num + "\nadjs:"+adjList);
        while(adjList.keySet().size() != 0) {
            boolean check = true;
            for(var temp : adjList.keySet()) {
                if(adjList.get(temp).size() < num) {
                    checkPointStack.push(temp);
                    checkEdgeStack.push(adjList.get(temp));
                    for(var temp1 : adjList.get(temp)) {
                        if(adjList.containsKey(temp1)) {
                            adjList.get(temp1).remove(temp);
                        }
                    }
                    adjList.remove(temp);
                    check = false;
                    break;
                }
            }
            if(check) {
                //System.out.println("cannot be colored.");
                exit(1);
            }
        }
        while(checkPointStack.size() != 0) {
            var temp = checkPointStack.pop();
            var adjSet = checkEdgeStack.pop();
            Set<Reg> notEqual = new TreeSet<>();
            for(var node : adjSet) {
                if(node instanceof Reg) {
                    notEqual.add((Reg) node);
                }else {
                    notEqual.add(bindings.get(node));
                }
            }
            //System.out.println("refill:"+temp+","+notEqual+":"+adjSet);
            allocRegByColor(temp,notEqual);
        }

        /*System.out.println("alloc reg finished. Data:");
        for(var key : bindings.keySet()) {
            System.out.println("temp:"+key+" reg:"+bindings.get(key));
        }*/
    }


    private void localAlloc(BasicBlock<PseudoInstr> bb, SubroutineEmitter subEmitter) {
        //System.out.println("new block.");
        var callerNeedSave = new ArrayList<Reg>();
/*
        if (!bb.isEmpty() && !bb.kind.equals(BasicBlock.Kind.CONTINUOUS)) {
            inits.clear();
            findInits(bb);
            for(var temp: inits) {
                subEmitter.emitLoadFromStack(bindings.get(temp), temp);
                bindings.get(temp).occupied = true;
                bindings.get(temp).temp = temp;
            }

        }*/

        for (var loc : bb.allSeq()) {
            // Handle special instructions on caller save/restore.

            if (loc.instr instanceof HoleInstr) {
                if (loc.instr.equals(HoleInstr.CallerSave)) {
                    for (var reg : emitter.callerSaveRegs) {
                        if (reg.occupied && loc.liveOut.contains(reg.temp)) {
                            callerNeedSave.add(reg);
                            subEmitter.emitStoreToStack(reg);
                        }
                    }
                    continue;
                }

                if (loc.instr.equals(HoleInstr.CallerRestore)) {
                    for (var reg : callerNeedSave) {
                        subEmitter.emitLoadFromStack(reg, reg.temp);
                    }
                    callerNeedSave.clear();
                    continue;
                }
            }

            // For normal instructions: allocate registers for every read/written temp. Skip the already specified
            // special registers.
            allocForLoc(loc, subEmitter);
        }

        // Handle the last instruction, if it is a branch/return block.
        if (!bb.isEmpty() && !bb.kind.equals(BasicBlock.Kind.CONTINUOUS)) {
            allocForLoc(bb.locs.get(bb.locs.size() - 1), subEmitter);
        }
    }

    private void allocForLoc(Loc<PseudoInstr> loc, SubroutineEmitter subEmitter) {
        var instr = loc.instr;
        var srcRegs = new Reg[instr.srcs.length];
        var dstRegs = new Reg[instr.dsts.length];
        //System.out.println("parse loc");

        for (var i = 0; i < instr.srcs.length; i++) {
            var temp = instr.srcs[i];
            if (temp instanceof Reg) {
                srcRegs[i] = (Reg) temp;
                srcRegs[i].occupied = true;
            } else {
                srcRegs[i] = bindings.get(temp);
                //System.out.println("src is " + temp + " " + srcRegs[i]);
                if(!loc.liveIn.contains(temp) || !srcRegs[i].occupied || srcRegs[i].temp != temp) {
                    //System.out.println("illegal load from stack:"+srcRegs[i]);
                    srcRegs[i].occupied = true;
                    srcRegs[i].temp = temp;
                    subEmitter.emitLoadFromStack(srcRegs[i], temp);
                }
            }

        }

        for (var i = 0; i < instr.dsts.length; i++) {
            var temp = instr.dsts[i];
            if (temp instanceof Reg) {
                dstRegs[i] = ((Reg) temp);
                dstRegs[i].occupied = true;
            } else {
                dstRegs[i] = bindings.get(temp);
                dstRegs[i].occupied = true;
                dstRegs[i].temp = temp;
            }
            //System.out.println("dst func " + temp +":"+dstRegs[i]);
        }

        subEmitter.emitNative(instr.toNative(dstRegs, srcRegs));
    }

//    private void allocForLoc_noemmit(Loc<PseudoInstr> loc, SubroutineEmitter subEmitter) {
//        var instr = loc.instr;
//        var srcRegs = new Reg[instr.srcs.length];
//        var dstRegs = new Reg[instr.dsts.length];
//        //System.out.println("parse loc");
//
//        for (var i = 0; i < instr.srcs.length; i++) {
//            var temp = instr.srcs[i];
//            if (temp instanceof Reg) {
//                srcRegs[i] = (Reg) temp;
//                srcRegs[i].occupied = true;
//            } else {
//                srcRegs[i] = bindings.get(temp);
//                //System.out.println("src is " + temp + " " + srcRegs[i]);
//                if(!loc.liveIn.contains(temp) || !srcRegs[i].occupied || srcRegs[i].temp != temp) {
//                    //System.out.println("load from stack:"+srcRegs[i]);
//                    srcRegs[i].occupied = true;
//                    srcRegs[i].temp = temp;
//                    //subEmitter.emitLoadFromStack(srcRegs[i], temp);
//                }
//            }
//
//        }
//
//        for (var i = 0; i < instr.dsts.length; i++) {
//            var temp = instr.dsts[i];
//            if (temp instanceof Reg) {
//                dstRegs[i] = ((Reg) temp);
//                dstRegs[i].occupied = true;
//            } else {
//                dstRegs[i] = bindings.get(temp);
//                dstRegs[i].occupied = true;
//                dstRegs[i].temp = temp;
//            }
//            //System.out.println("dst func " + temp +":"+dstRegs[i]);
//        }
//
//        subEmitter.emitNative(instr.toNative(dstRegs, srcRegs));
//    }

//    /**
//     * Allocate a register for a temp.
//     *
//     * @param temp       temp appeared in the pseudo instruction
//     * @param isRead     true = read, false = write
//     * @param live       set of live temps before executing this instruction
//     * @param subEmitter current subroutine emitter
//     * @return register for use
//     */
//   private Reg allocRegFor(Temp temp, boolean isRead, Set<Temp> live, SubroutineEmitter subEmitter) {
//        // Best case: the value of `temp` is already in register.
//        if (bindings.containsKey(temp)) {
//            return bindings.get(temp);
//        }
//
//        // First attempt: find an unoccupied register, or one whose value is no longer alive at this location.
//        for (var reg : emitter.allocatableRegs) {
//            if (!reg.occupied || !live.contains(reg.temp)) {
//                if (isRead) {
//                    // Since `reg` is uninitialized, we must load the latest value of `temp`, from stack, to `reg`.
//                    subEmitter.emitLoadFromStack(reg, temp);
//                }
//                if (reg.occupied) {
//                    unbind(reg.temp);
//                }
//                bind(temp, reg);
//                return reg;
//            }
//        }
//
//        // Last attempt: all registers are occupied, so we have to spill one of them.
//        // To avoid the situation where the first register is consecutively spilled, a reasonable heuristic
//        // is to randomize our choice among all of them.
//        var reg = emitter.allocatableRegs[random.nextInt(emitter.allocatableRegs.length)];
//        subEmitter.emitStoreToStack(reg);
//        unbind(reg.temp);
//        bind(temp, reg);
//        if (isRead) {
//            subEmitter.emitLoadFromStack(reg, temp);
//        }
//        return reg;
//    }

    private Reg allocRegByColor(Temp temp, Set<Reg> notEqual) {
        // Best case: the value of `temp` is already in register.
        if (bindings.containsKey(temp)) {
            return bindings.get(temp);
        }
        // First attempt: find an unoccupied register, or one whose value is no longer alive at this location.
        for (var reg : emitter.allocatableRegs) {
            if (!notEqual.contains(reg)) {
                bind(temp, reg);
                return reg;
            }
        }
        // Last attempt: all registers are occupied, so we have to spill one of them.
        // To avoid the situation where the first register is consecutively spilled, a reasonable heuristic
        // is to randomize our choice among all of them.
        //System.out.println("In Spill Session. Something went wrong.");
        var reg = emitter.allocatableRegs[random.nextInt(emitter.allocatableRegs.length)];
        //subEmitter.emitStoreToStack(reg);
        //unbind(reg.temp);
        bind(temp, reg);
        return reg;
    }

    /**
     * Random number generator.
     */
    private Random random = new Random();
}
