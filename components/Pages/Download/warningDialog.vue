<template>
  <el-dialog
    title="異常警示統計"
    :visible.sync="show"
    :before-close="resetForm"
    class="download-dialog"
    center
  >
    <div class="btn-list">
      <el-button
        plain
        size="medium"
        class="btn-month"
        :class="!isInterval ? 'is-active' : ''"
        @click="changeInterval(false)"
      >
        單月
      </el-button>
      <el-button
        plain
        size="medium"
        class="btn-range"
        :class="!isInterval ? '' : 'is-active'"
        @click="changeInterval(true)"
      >
        區間
      </el-button>
    </div>
    <div class="list">
      <!--單月-->
      <div class="block single-month" v-show="!isInterval">
        <el-form :model="ruleForm" :rules="rules" ref="ruleForm">
          <span class="demonstration">用電月份：</span>
          <el-form-item prop="month1">
            <el-date-picker
              v-model="ruleForm.month1"
              type="month"
              placeholder="請選擇月份"
              format="yyyy/MM"
              :editable="false"
              :picker-options="editStartOptions"
            >
            </el-date-picker>
          </el-form-item>
        </el-form>
      </div>
      <!--區間-->
      <div class="block range-month" v-show="isInterval">
        <el-form :model="ruleForm2" :rules="rules2" ref="ruleForm2">
          <span class="demonstration">用電月份：</span>
          <el-form-item prop="month2">
            <el-date-picker
              v-model="ruleForm2.month2"
              type="month"
              placeholder="請選擇月份"
              format="yyyy/MM"
              :editable="false"
              :picker-options="editStartOptions"
            >
            </el-date-picker>
          </el-form-item>
          <span class="text" style="padding-top: 1rem;">至</span>
          <el-form-item prop="month3">
            <el-date-picker
              v-model="ruleForm2.month3"
              type="month"
              placeholder="請選擇月份"
              format="yyyy/MM"
              :editable="false"
              :picker-options="editStopOptions"
            >
            </el-date-picker>
          </el-form-item>
        </el-form>
      </div>
    </div>
    <span slot="footer" class="dialog-footer">
      <el-button
        @click="
          !isInterval ? resetDialog('ruleForm') : resetDialog('ruleForm2')
        "
        >取消</el-button
      >
      <el-button
        type="primary"
        @click="
          !isInterval
            ? downloadPowerRecord('ruleForm')
            : downloadPowerRecord('ruleForm2')
        "
        >下載</el-button
      >
    </span>
  </el-dialog>
</template>

<script>
import backendApi from '@/assets/js/api/backendApi.js';
import dayjs from 'dayjs';

export default {
  props: {
    value: {
      type: Boolean,
      default: false,
    },
    isInterval: {
      type: Boolean,
      default: false,
    },
    loading: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      editStartOptions: {
        disabledDate: (time) => {
          if (!this.ruleForm2.month3) {
            return time.getTime() < new Date(1970 - 1 - 1).getTime(); // 禁止選擇1970年以前的日期
          }
          return time.getTime() > new Date(this.ruleForm2.month3);
        },
      },
      editStopOptions: {
        disabledDate: (time) => time.getTime() < new Date(this.ruleForm2.month2)
          || time.getTime() < new Date(1970 - 1 - 1).getTime(), // 禁止選擇1970年以前的日期
      },
      show: false,
      rules: {
        month1: [
          {
            type: 'date',
            required: true,
            message: '請選擇月份',
            trigger: 'blur',
          },
        ],
      },
      rules2: {
        month2: [
          {
            type: 'date',
            required: true,
            message: '請選擇起始月分',
            trigger: 'blur',
          },
        ],
        month3: [
          {
            type: 'date',
            required: true,
            message: '請選擇結束月分',
            trigger: 'blur',
          },
        ],
      },
      ruleForm: {
        month1: '',
      },
      ruleForm2: {
        month2: '',
        month3: '',
      },
      name: '',
      startMonth: '',
      endMonth: '',
    };
  },
  watch: {
    value(val) {
      const vm = this;
      vm.show = val;
    },
    show(val) {
      const vm = this;
      vm.$emit('input', val);
    },
  },
  methods: {
    downloadPowerRecord(formName) {
      const vm = this;

      vm.$refs[formName].validate((valid) => {
        if (valid) {
          if (formName === 'ruleForm') {
            vm.startMonth = dayjs(vm.ruleForm.month1).format('YYYY/MM');
            vm.endMonth = dayjs(vm.ruleForm.month1).format('YYYY/MM');
            vm.downloadError();
          } else if (formName === 'ruleForm2') {
            vm.startMonth = dayjs(vm.ruleForm2.month2).format('YYYY/MM');
            vm.endMonth = dayjs(vm.ruleForm2.month3).format('YYYY/MM');
            vm.downloadError('range');
          }
          vm.resetForm();
        }
      });
    },
    // 區間用電統計
    async downloadError(val) {
      const vm = this;
      const data = {
        startMonth: vm.startMonth,
        endMonth: vm.endMonth,
      };
      vm.changeLoading(true);
      const res = await backendApi.downloadError(data);
      if (res) {
        try {
          const uint8Msg = new Uint8Array(res);
          const newJson = String.fromCharCode.apply(null, uint8Msg);
          const newFile = JSON.parse(newJson);
          if (newFile.code === 4011) {
            vm.$message({
              message: '登入逾時',
              type: 'error',
            });
            window.$nuxt.$store.commit('user/CLEAR_USER_DATA');
            if (window.$nuxt.$route.name !== 'login') {
              window.$nuxt.$router.push('/login');
            }
          }
          if (newFile.code === 4002) {
            vm.$message({
              message: '權限錯誤',
              type: 'error',
            });
            window.$nuxt.$store.commit('user/CLEAR_USER_DATA');
            if (window.$nuxt.$route.name !== 'login') {
              window.$nuxt.$router.push('/login');
            }
          }
        } catch {
          if (val === 'range') {
            vm.name = `${vm.startMonth}-${vm.endMonth}`;
          } else {
            vm.name = vm.startMonth;
          }
          const a = document.createElement('a');
          const blob = new Blob([res], { type: 'application/excel' });
          a.href = window.URL.createObjectURL(blob);
          a.download = `${vm.name}異常警示統計.xlsx`;
          a.style.display = 'none';
          document.body.appendChild(a);
          a.click();
        }
      }
      vm.show = false;
      vm.changeLoading(false);
    },
    resetForm() {
      const vm = this;
      if (!vm.isInterval) {
        vm.resetDialog('ruleForm');
      } else {
        vm.resetDialog('ruleForm2');
      }
      vm.show = false;
    },
    resetDialog(formName) {
      const vm = this;
      vm.$refs[formName].resetFields();
      vm.show = false;
    },
    changeInterval(val) {
      const vm = this;
      vm.$emit('changeInterval', val);
    },
    changeLoading(val) {
      const vm = this;
      vm.$emit('changeLoading', val);
    },
  },
};
</script>
