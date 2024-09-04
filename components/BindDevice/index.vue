<template>
  <div class="register">
    <w-dialog v-model="show" title="綁定電器" width="1000px" @save="submitForm('ruleForm')" @cancel="closeDialog">
      <el-form ref="ruleForm" :model="ruleForm" :rules="rules" class="register-form" label-width="150px">
        <el-form-item v-if="deviceInfo.length" label="已綁定電器" class="register-item--full">
          <div class="device-info">
            <span>{{ bindDevice }}</span>
          </div>
        </el-form-item>
        <el-form-item label="總表ID" prop="ammeter" class="register-item--full">
          <div class="register-item__two-items">
            <el-input v-model="ruleForm.ammeter.ammeter1" :disabled="disabled" />
            <el-input v-model="ruleForm.ammeter.ammeter2" :disabled="disabled" />
          </div>
        </el-form-item>
        <device-and-slot-pc :disabled="disabled" :device-list="deviceList" :rule-form="ruleForm" />
        <el-form-item v-if="showGateway" prop="gatewayId" label="Gateway" class="register-item--full">
          <el-input v-model="ruleForm.gatewayId" />
        </el-form-item>
      </el-form>
    </w-dialog>
  </div>
</template>

<script>
import WDialog from '@/components/WDialog';
import DeviceAndSlotPc from '@/components/BindDevice/deviceAndSlotPc';
import FormChecker from '@/mixins/Components/BindDevice/formChecker';
import backendApi from '@/assets/js/api/backendApi.js';

export default {
  components: {
    WDialog,
    DeviceAndSlotPc,
  },
  mixins: [FormChecker],
  props: {
    value: {
      type: Boolean,
      default: false,
    },
    disabled: {
      type: Boolean,
      default: false,
    },
    showGateway: {
      type: Boolean,
      default: false,
    },
    deviceList: {
      type: Array,
      default: () => [],
    },
    deviceInfo: {
      type: Array,
      default: () => [],
    },
  },
  data() {
    const vm = this;
    return {
      show: false,
      ruleForm: {
        ammeter: {
          ammeter1: '',
          ammeter2: '',
        },
        device: {
          device1: '',
          device2: '',
          device3: '',
        },
        slot: {
          slot1: '',
          slot2: '',
          slot3: '',
        },
        gatewayId: '',
        userId: '',
        ntpc: '',
      },
      rules: {
        ammeter: [{ validator: vm.checkAmmeter }],
        device: [{ validator: vm.checkDevice }],
        slot: [{ validator: vm.checkSlot }],
        gatewayId: [{ validator: vm.checkGateway, required: vm.showGateway }],
      },
    };
  },
  computed: {
    bindDevice() {
      return this.deviceInfo.filter((e) => e.appId !== '10').map((e) => e.deviceName).join('、');
    },
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
    deviceInfo: {
      handler() {
        const vm = this;
        if (!vm.deviceInfo.length) return;
        vm.setData();
      },
    },
  },
  methods: {
    setData() {
      const vm = this;
      const ammeterList = vm.deviceInfo.filter((e) => e.appId === '10');
      ammeterList.forEach((e, index) => {
        vm.ruleForm.ammeter[`ammeter${index + 1}`] = e.deviceId;
      });

      const appList = vm.deviceInfo.filter((e) => e.appId !== '10');
      appList.forEach((e, index) => {
        vm.ruleForm.device[`device${index + 1}`] = e.appId;
        vm.ruleForm.slot[`slot${index + 1}`] = e.deviceId;
      });

      vm.ruleForm.gatewayId = vm.deviceInfo[0].gatewayId;
      vm.ruleForm.userId = vm.deviceInfo[0].userId;
      vm.ruleForm.ntpc = vm.deviceInfo[0].belongNtpc;
    },
    closeDialog() {
      const vm = this;
      vm.show = false;
      vm.reset();
    },
    reset() {
      const vm = this;
      vm.$nextTick(() => vm.$refs.ruleForm.clearValidate());
      Object.keys(vm.ruleForm.ammeter).forEach((key) => {
        vm.ruleForm.ammeter[key] = '';
      });
      Object.keys(vm.ruleForm.device).forEach((key) => {
        vm.ruleForm.device[key] = '';
      });
      Object.keys(vm.ruleForm.slot).forEach((key) => {
        vm.ruleForm.slot[key] = '';
      });
    },
    submitForm(formName) {
      const vm = this;
      vm.$refs[formName].validate((valid) => {
        if (valid) {
          vm.deviceBind();
        } else {
          console.log('error');
        }
      });
    },
    async deviceBind() {
      const vm = this;
      const obj = {
        ...vm.ruleForm,
        ammeterList: `${vm.ruleForm.ammeter.ammeter1},${vm.ruleForm.ammeter.ammeter2}`,
        appIdList: `${vm.ruleForm.device.device1},${vm.ruleForm.device.device2},${vm.ruleForm.device.device3}`,
        socketList: `${vm.ruleForm.slot.slot1},${vm.ruleForm.slot.slot2},${vm.ruleForm.slot.slot3}`,
      };
      const res = await backendApi.deviceBind(obj);
      if (res.code === 200 && res.data) {
        vm.$message.success('操作成功');
        vm.closeDialog();
      } else {
        vm.$message.error('操作失敗');
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.register {
  width: 100%;
  padding: 0 3rem;

  &-form {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
  }

  &-item {
    flex-basis: 48%;

    &--full {
      flex-basis: 100%;
    }

    &__two-items {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 0 10px;
    }
  }
}

.device-info {
  color: #333;
  font-weight: bold;
  font-size: 1.25rem;
}

/* 表單 */

/deep/ .el-form {
  &-item {
    display: flex;
    align-items: center;
    margin-bottom: 20px !important;

    &__label {
      flex-basis: unset !important;
      padding: 0;
      color: #333;
      font-weight: bolder;
      font-size: 1.25rem;
      text-align: left;

      &::before {
        display: none;
      }
    }

    &__content {
      flex-basis: 100%;
      margin-left: 0 !important;
    }
  }
}

/deep/ .el-input, /deep/ .el-select {
  width: 100%;
}
</style>
